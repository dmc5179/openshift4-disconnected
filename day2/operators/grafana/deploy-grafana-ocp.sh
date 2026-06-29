#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# ==========================================
# CONFIGURATION VARIABLES (Adjust as needed)
# ==========================================
NAMESPACE="monitoring-apps"
OPERATOR_CHANNEL="v5" # Adjust based on the latest Grafana Operator version available
CLUSTER_DOMAIN=$(oc get ingresses.config.openshift.io cluster -o jsonpath='{.spec.domain}')
API_URL=$(oc whoami --show-server)

echo "===================================================="
echo "🚀 Starting Grafana Deployment Pipeline on OpenShift"
echo "===================================================="
echo "Detected Cluster Domain: ${CLUSTER_DOMAIN}"
echo "Detected API Server URL: ${API_URL}"

# --------------------------------------------------
# Step 1: Create Namespace
# --------------------------------------------------
echo "✨ Creating Namespace: ${NAMESPACE}..."
oc create namespace "${NAMESPACE}" --dry-run=client -o yaml | oc apply -f -

# --------------------------------------------------
# Step 2: Install Grafana Operator
# --------------------------------------------------
echo "📦 Installing Grafana Operator via OperatorHub..."
cat <<EOF | oc apply -f -
apiVersion: ://coreos.com
kind: OperatorGroup
metadata:
  name: grafana-operator-group
  namespace: ${NAMESPACE}
spec:
  targetNamespaces:
  - ${NAMESPACE}
---
apiVersion: ://coreos.comalpha1
kind: Subscription
metadata:
  name: grafana-operator
  namespace: ${NAMESPACE}
spec:
  channel: ${OPERATOR_CHANNEL}
  name: grafana-operator
  source: community-operators
  sourceNamespace: openshift-marketplace
EOF

echo "⏳ Waiting for Grafana Operator to be ready..."
oc wait --namespace="${NAMESPACE}" \
  --for=condition=CatalogSourcesUnhealthy=False \
  sub/grafana-operator --timeout=120s

# Wait a brief moment for CSV to register and deployment to spin up
sleep 15
oc wait --namespace="${NAMESPACE}" \
  --for=condition=Available \
  deployment/grafana-operator-controller-manager --timeout=120s

# --------------------------------------------------
# Step 3: Register Grafana as an OAuth Client
# --------------------------------------------------
echo "🔒 Creating ServiceAccount for OpenShift OAuth Integration..."
cat <<EOF | oc apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: grafana-oauth
  namespace: ${NAMESPACE}
  annotations:
    serviceaccounts.openshift.io/oauth-redirectreference.primary: |-
      {"kind":"OAuthRedirectReference","apiVersion":"v1","reference":{"kind":"Route","name":"grafana-route"}}
EOF

echo "🔑 Extracting ServiceAccount token for OAuth Client Secret..."
# Create a dedicated long-lived token secret since OpenShift 4.11+ no longer auto-generates them
cat <<EOF | oc apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: grafana-oauth-token
  namespace: ${NAMESPACE}
  annotations:
    kubernetes.io/service-account.name: grafana-oauth
type: kubernetes.io/service-account-token
EOF

# Give OpenShift a second to populate the secret token
sleep 5
CLIENT_SECRET=$(oc get secret grafana-oauth-token -n "${NAMESPACE}" -o jsonpath='{.data.token}' | base64 --decode)

if [ -z "$CLIENT_SECRET" ]; then
    echo "❌ Error: Failed to extract OAuth Client Secret."
    exit 1
fi

# --------------------------------------------------
# Step 4: Deploy Configured Grafana Instance
# --------------------------------------------------
echo "📊 Deploying Grafana Instance with OpenShift RBAC/OAuth Mapping..."
cat <<EOF | oc apply -f -
apiVersion: grafana.integreatly.org/v1beta1
kind: Grafana
metadata:
  name: grafana-oss
  namespace: ${NAMESPACE}
spec:
  ingress:
    enabled: true
    targetPort: 3000
    termination: edge
  config:
    server:
      root_url: "https://grafana-route-${NAMESPACE}.apps.${CLUSTER_DOMAIN}"
    auth.generic_oauth:
      enabled: "true"
      name: "OpenShift Login"
      allow_sign_up: "true"
      client_id: "system:serviceaccount:${NAMESPACE}:grafana-oauth"
      client_secret: "${CLIENT_SECRET}"
      scopes: "user:info user:check-access"
      auth_url: "https://oauth-openshift.apps.${CLUSTER_DOMAIN}/oauth/authorize"
      token_url: "https://oauth-openshift.apps.${CLUSTER_DOMAIN}/oauth/token"
      api_url: "${API_URL}/apis/user.openshift.io/v1/users/~"
      role_attribute_path: "contains(groups, 'cluster-admins') && 'Admin' || contains(groups, 'dev-lead') && 'Editor' || 'Viewer'"
      groups_attribute_path: "groups"
EOF

# --------------------------------------------------
# Step 5: Expose the Grafana Route explicitly
# --------------------------------------------------
echo "🌐 Ensuring the Route matches the OAuth redirect reference name..."
# The operator dynamically builds the route name based on ingress definitions, let's patch/verify its name
# Force create/override the exact route name the OAuth client expects
oc create route edge grafana-route \
  --service=grafana-oss-service \
  --port=grafana-http \
  --hostname="grafana-route-${NAMESPACE}.apps.${CLUSTER_DOMAIN}" \
  -n "${NAMESPACE}" --dry-run=client -o yaml | oc apply -f -

echo "===================================================="
echo "✅ Deployment Successful!"
echo "===================================================="
echo "Grafana URL: https://grafana-route-${NAMESPACE}.apps.${CLUSTER_DOMAIN}"
echo "Log in using your cluster OpenShift credentials."
echo "===================================================="

