#!/bin/bash

# ============================================================================
# Configuration variables
# ============================================================================

# Gateway and namespace configuration
INGRESS_NS=openshift-ingress
GW_CLASS_NAME=openshift-default
NAMESPACE=test-ns
SERVICE_NAME=llm-basic
GATEWAY_NAME=openshift-ai-inference

# WASM configuration for disconnected clusters
# NOTE: Update these variables to match your mirror registry
MIRROR_REGISTRY="bastion.ods-dis-psi-03.osp.rh-ods.com:8443"
WASM_IMAGE_DIGEST="sha256:aa524e9278976aa3ef0f2d3aeb981e28d2ea6ed6fc5fede05a5dd33db0bb3de2"
# The WASM module is: registry.access.redhat.com/rhcl-1/wasm-shim-rhel9@${WASM_IMAGE_DIGEST}
# It must be mirrored to: ${MIRROR_REGISTRY}/rhcl-1/wasm-shim-rhel9@${WASM_IMAGE_DIGEST}

echo "=== Deploying and Testing LLMInferenceService in Disconnected Environment ==="
echo ""
echo "This script implements a working configuration for manual testing of llm-d in disconnected clusters:"
echo "  1. Kuadrant Subscription with RELATED_IMAGE_WASMSHIM and PROTECTED_REGISTRY"
echo "  2. ConfigMap to force ClusterIP service type (instead of LoadBalancer)"
echo "  3. Gateway with parametersRef to ConfigMap + WASM_INSECURE_REGISTRIES"
echo "  4. Route with TLS edge termination for external HTTPS access"
echo "  5. wasm-plugin-pull-secret for authenticated WASM module download"
echo ""

# ============================================================================
# BACKGROUND: Investigation Summary
# ============================================================================
#
# Problem 1: Gateway Not Programmed
#   Symptom: Gateway stuck at Programmed=False, reason: AddressNotAssigned
#   Root Cause: LoadBalancer service waiting for external IP that doesn't exist
#                in disconnected/bare-metal clusters (no cloud provider integration)
#   Solution: ConfigMap with type: ClusterIP + OpenShift Route for external access
#
# Problem 2: WASM Module Download Failure (TLS Certificate)
#   Symptom: HTTP 403 "RBAC: access denied" for all requests
#   Root Cause: Envoy logs showed "x509: certificate signed by unknown authority"
#                WasmPlugin tries to download from registry.access.redhat.com
#                Cluster is disconnected → timeout → failureMode: deny
#   Investigation: Gateway pod logs: oc logs <gateway-pod> | grep -i wasm
#   Solution: WASM_INSECURE_REGISTRIES env var (from Istio issue #36571)
#             Reference: https://github.com/istio/istio/issues/36571
#
# Problem 3: WASM Module Authentication
#   Symptom: UNAUTHORIZED when pulling from mirror registry
#   Root Cause: WasmPlugin doesn't automatically use Kubernetes imagePullSecrets
#   Solution: WasmPlugin.spec.imagePullSecret field
#             Reference: https://istio.io/latest/docs/tasks/extensibility/wasm-module-distribution/
#
# Problem 4: Kuadrant Operator Removes imagePullSecret (FIXED in PR #1083)
#   Symptom: imagePullSecret field removed from WasmPlugin spec within ~30 seconds
#   Root Cause: Kuadrant operator reconciler didn't support imagePullSecret configuration
#   Solution (upstream fix - PR #1083, merged Dec 19, 2024):
#     - Set PROTECTED_REGISTRY env var in Subscription to mirror registry hostname
#     - Operator now automatically injects imagePullSecret when WASM URL matches PROTECTED_REGISTRY
#     - Secret must be named "wasm-plugin-pull-secret" (hardcoded in operator)
#     - No more operator downtime workaround needed!
#   Reference: https://github.com/Kuadrant/kuadrant-operator/pull/1083
#
# Traffic Flow:
#   Client → Route (HTTPS, TLS edge termination)
#        → Gateway Service (HTTP on ClusterIP:80)
#        → Gateway Pod/Envoy (processes HTTPRoute, applies AuthPolicy via WASM)
#        → Backend Pod (vLLM)
#
# ============================================================================
# DEPLOYMENT SECTION
# ============================================================================

echo "=== Deployment Phase ==="

# Step 1: Configure Kuadrant Operator Subscription with mirrored WASM image
# ----------------------------------------------------------------------------
# Why patch the Subscription?
#   - Kuadrant operator creates WasmPlugin resources automatically
#   - Default WASM image URL is registry.access.redhat.com (not accessible)
#   - RELATED_IMAGE_WASMSHIM env var tells operator which image to use
#   - PROTECTED_REGISTRY env var tells operator to inject imagePullSecret
#   - Subscription is managed by OLM, persists across operator restarts
#
# How it works (PR #1083):
#   - If WASM image URL contains PROTECTED_REGISTRY → operator injects imagePullSecret
#   - The secret MUST be named "wasm-plugin-pull-secret" (hardcoded in operator)
# ----------------------------------------------------------------------------
echo "[1/10] Configuring Kuadrant Operator Subscription with mirror registry..."

if oc get subscription rhcl-operator -n kuadrant-system &>/dev/null; then
  CURRENT_WASM_IMAGE=$(oc get subscription rhcl-operator -n kuadrant-system -o jsonpath='{.spec.config.env[?(@.name=="RELATED_IMAGE_WASMSHIM")].value}' 2>/dev/null)
  CURRENT_PROTECTED_REG=$(oc get subscription rhcl-operator -n kuadrant-system -o jsonpath='{.spec.config.env[?(@.name=="PROTECTED_REGISTRY")].value}' 2>/dev/null)

  if [ "$CURRENT_WASM_IMAGE" = "oci://${MIRROR_REGISTRY}/rhcl-1/wasm-shim-rhel9@${WASM_IMAGE_DIGEST}" ] && [ "$CURRENT_PROTECTED_REG" = "${MIRROR_REGISTRY}" ]; then
    echo "  ✓ Subscription already configured with mirror registry and PROTECTED_REGISTRY"
  else
    echo "  Patching Subscription with RELATED_IMAGE_WASMSHIM and PROTECTED_REGISTRY..."
    oc patch subscription rhcl-operator -n kuadrant-system --type=merge -p "{
      \"spec\": {
        \"config\": {
          \"env\": [
            {
              \"name\": \"RELATED_IMAGE_WASMSHIM\",
              \"value\": \"oci://${MIRROR_REGISTRY}/rhcl-1/wasm-shim-rhel9@${WASM_IMAGE_DIGEST}\"
            },
            {
              \"name\": \"PROTECTED_REGISTRY\",
              \"value\": \"${MIRROR_REGISTRY}\"
            }
          ]
        }
      }
    }"

    if [ $? -eq 0 ]; then
      echo "  ✓ Subscription patched successfully"
      echo "  Waiting for operator to restart with new configuration..."
      sleep 10
    else
      echo "  Error: Failed to patch Subscription"
      exit 1
    fi
  fi
else
  echo "  Warning: rhcl-operator Subscription not found"
  echo "  This is required for automatic WASM image configuration"
  exit 1
fi

# Step 2: Apply the GatewayClass resource
echo "[2/10] Creating GatewayClass..."
oc apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: ${GW_CLASS_NAME}
spec:
  controllerName: "openshift.io/gateway-controller/v1"
EOF

if [ $? -ne 0 ]; then
  echo "Error: Failed to apply GatewayClass"
  exit 1
fi

# Step 3: Create ConfigMap to force ClusterIP service type and configure WASM
# ----------------------------------------------------------------------------
# This ConfigMap serves two purposes:
# 1. Forces ClusterIP instead of LoadBalancer (via spec.infrastructure.parametersRef)
# 2. Injects WASM_INSECURE_REGISTRIES env var into Gateway deployment
#
# Why WASM_INSECURE_REGISTRIES?
#   - Mirror registry uses self-signed certificate
#   - Envoy's WASM fetcher needs to skip TLS verification
# ----------------------------------------------------------------------------
echo "[3/10] Creating ConfigMap with ClusterIP and WASM configuration..."
oc apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: ${GATEWAY_NAME}-config
  namespace: ${INGRESS_NS}
data:
  service: |
    metadata:
      annotations:
        service.beta.openshift.io/serving-cert-secret-name: "${GATEWAY_NAME}-service-tls"
    spec:
      type: ClusterIP
  deployment: |
    spec:
      template:
        spec:
          containers:
          - name: istio-proxy
            env:
            - name: WASM_INSECURE_REGISTRIES
              value: ${MIRROR_REGISTRY}
EOF

if [ $? -ne 0 ]; then
  echo "Error: Failed to create ConfigMap"
  exit 1
fi

# Step 4: Apply the Gateway resource with parametersRef
echo "[4/10] Creating Gateway with ClusterIP configuration..."
oc apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: ${GATEWAY_NAME}
  namespace: ${INGRESS_NS}
  labels:
    serving.kserve.io/gateway: kserve-ingress-gateway
spec:
  gatewayClassName: ${GW_CLASS_NAME}
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: All
  infrastructure:
    parametersRef:
      group: ""
      kind: ConfigMap
      name: ${GATEWAY_NAME}-config
EOF

if [ $? -ne 0 ]; then
  echo "Error: Failed to apply Gateway"
  exit 1
fi

# Step 5: Create pull-secret for WASM module authentication (copy from cluster pull-secret)
# ----------------------------------------------------------------------------
# Why this is needed:
#   - WasmPlugin needs to pull OCI image from authenticated registry
#   - Cluster pull-secret exists in openshift-config namespace
#   - WasmPlugin in openshift-ingress namespace can't access it
#   - Must copy secret to same namespace as WasmPlugin
#
# IMPORTANT: Secret name MUST be "wasm-plugin-pull-secret"
#   - This is hardcoded in the Kuadrant operator (PR #1083)
#   - When PROTECTED_REGISTRY env var is set, operator automatically injects
#     imagePullSecret: "wasm-plugin-pull-secret" into WasmPlugin spec
# ----------------------------------------------------------------------------
echo "[5/10] Ensuring pull-secret exists for WASM module registry..."
if oc get secret wasm-plugin-pull-secret -n ${INGRESS_NS} &>/dev/null; then
  echo "  ✓ Pull-secret already exists"
else
  echo "  Creating wasm-plugin-pull-secret from cluster pull-secret..."
  oc get secret pull-secret -n openshift-config -o json 2>/dev/null | \
    jq 'del(.metadata.namespace,.metadata.resourceVersion,.metadata.uid,.metadata.creationTimestamp,.metadata.ownerReferences)' | \
    jq '.metadata.name="wasm-plugin-pull-secret"' | \
    oc apply -n ${INGRESS_NS} -f -

  if [ $? -eq 0 ]; then
    echo "  ✓ Pull-secret created successfully"
  else
    echo "  Error: Failed to create pull-secret"
    exit 1
  fi
fi

# Step 6: Wait for Gateway to become Programmed
echo "[6/10] Waiting for Gateway to become Programmed=True..."
MAX_WAIT=120
ELAPSED=0
PROGRAMMED="False"

while [ $ELAPSED -lt $MAX_WAIT ]; do
  PROGRAMMED=$(oc get gateway ${GATEWAY_NAME} -n ${INGRESS_NS} -o jsonpath='{.status.conditions[?(@.type=="Programmed")].status}' 2>/dev/null)
  if [ "$PROGRAMMED" = "True" ]; then
    echo "✓ Gateway is Programmed!"
    break
  fi
  sleep 5
  ELAPSED=$((ELAPSED + 5))
  echo "  Waiting for Gateway Programmed... (${ELAPSED}s/${MAX_WAIT}s)"
done

if [ "$PROGRAMMED" != "True" ]; then
  echo "Error: Gateway did not become Programmed after ${MAX_WAIT} seconds"
  echo "Gateway status:"
  oc get gateway ${GATEWAY_NAME} -n ${INGRESS_NS} -o jsonpath='{.status.conditions[?(@.type=="Programmed")]}'
  exit 1
fi

# Step 7: Create Route with TLS edge termination
echo "[7/10] Creating Route with TLS edge termination..."
GATEWAY_SERVICE="${GATEWAY_NAME}-${GW_CLASS_NAME}"

oc apply -f - <<EOF
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: ${GATEWAY_NAME}
  namespace: ${INGRESS_NS}
spec:
  to:
    kind: Service
    name: ${GATEWAY_SERVICE}
    weight: 100
  port:
    targetPort: http
  tls:
    termination: edge
    insecureEdgeTerminationPolicy: Redirect
  wildcardPolicy: None
EOF

if [ $? -ne 0 ]; then
  echo "Error: Failed to create Route"
  exit 1
fi

# Get Route hostname
ROUTE_HOST=$(oc get route ${GATEWAY_NAME} -n ${INGRESS_NS} -o jsonpath='{.spec.host}')
echo "✓ Route created with hostname: ${ROUTE_HOST}"

# Step 8: Create the application namespace
echo "[8/10] Creating namespace ${NAMESPACE}..."
oc create namespace "${NAMESPACE}" --dry-run=client -o yaml | oc apply -f - || true

# Step 9: Deploy the LLMInferenceService
# ----------------------------------------------------------------------------
echo "[9/10] Deploying LLMInferenceService ${SERVICE_NAME}..."
oc apply -f - <<EOF
apiVersion: serving.kserve.io/v1alpha1
kind: LLMInferenceService
metadata:
  annotations:
    security.opendatahub.io/enable-auth: 'false'
  name: ${SERVICE_NAME}
  namespace: ${NAMESPACE}
spec:
  model:
    uri: 'oci://quay.io/mwaykole/test@sha256:8bfd02132b03977ebbca93789e81c4549d8f724ee78fa378616d9ae4387717c8'
  replicas: 1
  router:
    gateway: {}
    route: {}
    scheduler: {}
  template:
    containers:
      - env:
          - name: VLLM_LOGGING_LEVEL
            value: DEBUG
          - name: VLLM_ADDITIONAL_ARGS
            value: "--ssl-ciphers ECDHE+AESGCM:DHE+AESGCM"
          - name: VLLM_CPU_KVCACHE_SPACE
            value: "4"
        image: 'quay.io/pierdipi/vllm-cpu@sha256:ce3a0c057394b2c332498f9742a17fd31b5cc2ef07db882d579fd157fe2c9a98'
        name: main
        resources:
          limits:
            cpu: '2'
            memory: 10Gi
          requests:
            cpu: 500m
            memory: 4Gi
EOF

if [ $? -ne 0 ]; then
  echo "Error: Failed to apply LLMInferenceService"
  exit 1
fi

# Step 10: Wait for service to be ready
echo "[10/10] Waiting for LLMInferenceService to be ready..."
MAX_WAIT=600  # Increased to 10 minutes for model loading
ELAPSED=0
READY="False"

while [ $ELAPSED -lt $MAX_WAIT ]; do
  READY=$(oc get llminferenceservice ${SERVICE_NAME} -n ${NAMESPACE} -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null)
  if [ "$READY" = "True" ]; then
    echo "✓ LLMInferenceService is ready!"
    break
  fi
  sleep 10
  ELAPSED=$((ELAPSED + 10))
  echo "  Waiting for backend pods... (${ELAPSED}s/${MAX_WAIT}s)"
done

if [ "$READY" != "True" ]; then
  echo "Warning: Service not Ready after ${MAX_WAIT} seconds (current status: ${READY})"
  echo "Proceeding with WasmPlugin configuration anyway..."
fi

echo "=== Deployment complete ==="
echo ""

# ============================================================================
# TESTING SECTION
# ============================================================================

echo "=== Testing Phase ==="
echo ""
echo "Testing LLM inference endpoint..."

# ----------------------------------------------------------------------------
# Testing strategy:
#   - Use Route hostname (not internal service URL from LLMInferenceService.status.url)
#   - LLMInferenceService.status.url contains cluster-internal service URL
#   - Route provides external access via OpenShift Router
#
# Expected results:
#   - HTTP 200: Success! LLM responds with answer
# Errors:
#   - HTTP 403: Gateway routing works, RBAC blocks
#   - HTTP 503: Envoy can't reach backend
#   - Timeout: Route/Gateway/Backend not ready
#
# Success indicators in logs (oc logs <gateway-pod>):
#   ✓ "wasm fetching image ... from registry bastion..."
#   ✓ "Envoy proxy is ready"
#   ✗ "error in converting the wasm config to local" → WASM download failed
#   ✗ "applying deny RBAC filter" → WasmPlugin not loaded
# ----------------------------------------------------------------------------

# Construct test URL using Route hostname (not internal service URL)
TEST_ENDPOINT="https://${ROUTE_HOST}/${NAMESPACE}/${SERVICE_NAME}/v1/chat/completions"

echo "Testing endpoint: ${TEST_ENDPOINT}"
echo "  (Using Route hostname for external access)"
echo ""

# Run curl test with increased timeout
RESPONSE=$(timeout 60 curl -k -i -s -X POST \
  -d '{"model": "'"${SERVICE_NAME}"'", "messages": [{"role": "user", "content": "What is the capital of France?"}], "max_tokens": 50, "temperature": 0.0, "stream": false}' \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  "${TEST_ENDPOINT}" 2>&1)

CURL_EXIT=$?
if [ $CURL_EXIT -eq 124 ]; then
  echo "✗ Test timed out after 60 seconds"
  exit 1
elif [ $CURL_EXIT -ne 0 ]; then
  echo "✗ Curl failed with exit code ${CURL_EXIT}"
  echo "$RESPONSE"
  exit 1
fi

HTTP_CODE=$(echo "$RESPONSE" | head -n 1 | grep -oE '[0-9]{3}' | head -n 1)
# Extract body - find the first blank line and get everything after it
BODY=$(echo "$RESPONSE" | sed -n '/^\r$/,$p' | sed '1d' | sed 's/^\r$//')
# If that didn't work, try without \r
if [ -z "$BODY" ]; then
  BODY=$(echo "$RESPONSE" | sed -n '/^$/,$p' | sed '1d')
fi

echo "HTTP Status: ${HTTP_CODE}"
echo ""

if [ "$HTTP_CODE" = "200" ]; then
  echo "✓ Test successful!"
  echo ""
  # Extract content from message
  CONTENT=$(echo "$BODY" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('choices', [{}])[0].get('message', {}).get('content', ''))" 2>/dev/null)
  if [ -n "$CONTENT" ]; then
    echo "Message Content:"
    echo "$CONTENT"
  else
    echo "Full Response:"
    echo "$BODY"
  fi
  echo ""
  echo "=== ✓ Deployment and Testing Complete ==="
  exit 0
elif [ "$HTTP_CODE" = "403" ]; then
  echo "⚠ Test returned 403 Forbidden (RBAC: access denied)"
  echo "This indicates the Gateway is working and routing correctly,"
  echo "but authentication is required."
  echo ""
  echo "Response:"
  echo "$BODY"
  echo ""
  echo "=== Deployment Complete, Authentication Required ==="
  exit 0
else
  echo "✗ Test failed with HTTP ${HTTP_CODE}"
  echo ""
  echo "Response:"
  echo "$RESPONSE"
  echo ""
  echo "Debug information:"
  echo "  Gateway status: $(oc get gateway ${GATEWAY_NAME} -n ${INGRESS_NS} -o jsonpath='{.status.conditions[?(@.type=="Programmed")].status}')"
  echo "  Route host: ${ROUTE_HOST}"
  echo "  LLMInferenceService Ready: $(oc get llminferenceservice ${SERVICE_NAME} -n ${NAMESPACE} -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}')"
  echo ""
  echo "=== Deployment Complete, Testing Failed ==="
  exit 1
fi

# ============================================================================
# TROUBLESHOOTING GUIDE
# ============================================================================
#
# Common Issues:
#
# 1. Gateway stuck at Programmed=False
#    → Check: oc get gateway ${GATEWAY_NAME} -n ${INGRESS_NS} -o yaml
#    → Look for: status.conditions[?(@.type=="Programmed")]
#    → Fix: Verify ConfigMap has type: ClusterIP
#
# 2. HTTP 403 "RBAC: access denied"
#    → Check Gateway logs: oc logs -n ${INGRESS_NS} -l gateway.networking.k8s.io/gateway-name=${GATEWAY_NAME} | grep -i wasm
#    → If "applying deny RBAC filter": WASM module failed to load
#    → If "x509: certificate signed by unknown authority": Need WASM_INSECURE_REGISTRIES
#    → If "UNAUTHORIZED": Need imagePullSecret or verify Subscription config
#
# 3. WASM module downloading from wrong registry
#    → Check Subscription: oc get subscription rhcl-operator -n kuadrant-system -o yaml | grep -A 5 RELATED_IMAGE_WASMSHIM
#    → Verify it points to mirror: Should be ${MIRROR_REGISTRY}/rhcl-1/wasm-shim-rhel9@${WASM_IMAGE_DIGEST}
#    → Check WasmPlugin URL: oc get wasmplugin kuadrant-${GATEWAY_NAME} -n ${INGRESS_NS} -o jsonpath='{.spec.url}'
#    → If wrong, re-run Step 1 to patch Subscription
#
# 4. WASM module not downloading (UNAUTHORIZED)
#    → Verify mirror registry has image:
#      podman pull --tls-verify=false ${MIRROR_REGISTRY}/rhcl-1/wasm-shim-rhel9@${WASM_IMAGE_DIGEST}
#    → Check WasmPlugin has imagePullSecret:
#      oc get wasmplugin kuadrant-${GATEWAY_NAME} -n ${INGRESS_NS} -o jsonpath='{.spec.imagePullSecret}'
#    → If imagePullSecret is missing or null:
#      - Check PROTECTED_REGISTRY is set in Subscription (Step 1)
#      - Operator should automatically inject imagePullSecret: "wasm-plugin-pull-secret"
#    → Verify secret exists: oc get secret wasm-plugin-pull-secret -n ${INGRESS_NS}
#
# 5. Gateway pod restarted and WASM errors returned
#    → With PROTECTED_REGISTRY configured, imagePullSecret persists through restarts
#    → Check that wasm-plugin-pull-secret exists in openshift-ingress namespace
#    → Quick check: oc logs <gateway-pod> -n ${INGRESS_NS} | grep -i "wasm.*error"
#
# 6. Subscription patch not persisting
#    → Check if OLM reverted it: oc get csv -n kuadrant-system
#    → Subscription is the correct place for OLM-managed operators
#    → If reverted, may need to patch CSV directly (not recommended)
#
# References:
#   - Kuadrant PROTECTED_REGISTRY fix: https://github.com/Kuadrant/kuadrant-operator/pull/1083
#   - Istio WASM insecure registry: https://github.com/istio/istio/issues/36571
#   - WasmPlugin imagePullSecret: https://istio.io/latest/docs/tasks/extensibility/wasm-module-distribution/
#   - OpenShift Gateway API: https://docs.openshift.com/container-platform/latest/networking/hardware_networks/about-openshift-gateway.html
#   - OLM Subscription config: https://olm.operatorframework.io/docs/concepts/crds/subscription/
#
# ============================================================================
