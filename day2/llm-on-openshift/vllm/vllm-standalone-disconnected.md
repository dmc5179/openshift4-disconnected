# Serving gpt-oss-120b with Red Hat AI Inference (vLLM) in a Disconnected OpenShift Enclave

This guide covers deploying the official Red Hat AI Inference (vLLM) container on
OpenShift in a fully air-gapped enclave, with the `gpt-oss-120b` model kept as a
standalone, reusable artifact that can be mounted into any serving runtime.

> **Product note:** Red Hat AI Inference (formerly "Red Hat AI Inference Server" /
> RHAIIS) is the standalone, supported vLLM distribution from Red Hat. It runs
> independently of OpenShift AI and provides an OpenAI-compatible API.

## Prerequisites

| Requirement | Details |
|---|---|
| OpenShift Container Platform | 4.17+ (disconnected install) |
| NVIDIA GPUs | 1x H100 or A100 80 GB (MXFP4 MoE weights fit on a single 80 GB GPU) |
| Operators installed | Node Feature Discovery (NFD), NVIDIA GPU Operator |
| Mirror registry | A container registry accessible inside the enclave (e.g. `mirror.enclave.local:5000`) |
| `oc-mirror` v2 | Installed on the connected workstation used for mirroring |
| Red Hat subscription | For pulling images from `registry.redhat.io` |

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  Connected Side                                                 │
│                                                                 │
│  registry.redhat.io ──► oc-mirror ──► disk archive (.tar)       │
│  model weights (HF)  ──► tar/skopeo ──► disk archive           │
└────────────────────────────┬────────────────────────────────────┘
                             │  sneakernet / data diode
┌────────────────────────────▼────────────────────────────────────┐
│  Disconnected Enclave (OpenShift)                               │
│                                                                 │
│  mirror.enclave.local:5000  ◄── load archives                  │
│       │                                                         │
│       ├── rhaii/vllm-cuda-rhel9:3.4.1    (runtime)             │
│       └── gpt-oss-120b-modelcar:latest   (model, if using OCI) │
│                                                                 │
│  PersistentVolume ◄── model weights (if using PVC approach)    │
│       │                                                         │
│       └── mounted at /models/gpt-oss-120b in vLLM pod          │
└─────────────────────────────────────────────────────────────────┘
```

---

## Step 1: Mirror Container Images to Disk

### Images to Mirror

The following images must be mirrored for transport into the enclave:

| Image | Purpose |
|---|---|
| `registry.redhat.io/rhaii/vllm-cuda-rhel9:3.4.1` | Red Hat AI Inference (vLLM) runtime |
| `registry.redhat.io/redhat/redhat-operator-index:v4.17` | Operator catalog (match your OCP version) |
| `registry.redhat.io/redhat/certified-operator-index:v4.17` | Certified operator catalog (NVIDIA GPU Operator) |

> Adjust the catalog image tags (e.g. `v4.17`, `v4.18`, `v4.20`) to match your
> OpenShift cluster version.

### ImageSetConfiguration for oc-mirror

Save this as `imageset-config.yaml` on your connected workstation:

```yaml
apiVersion: mirror.openshift.io/v2alpha1
kind: ImageSetConfiguration
mirror:
  operators:
    # Node Feature Discovery (NFD) Operator
    - catalog: registry.redhat.io/redhat/redhat-operator-index:v4.17
      packages:
        - name: nfd
    # NVIDIA GPU Operator
    - catalog: registry.redhat.io/redhat/certified-operator-index:v4.17
      packages:
        - name: gpu-operator-certified
  additionalImages:
    # Red Hat AI Inference (vLLM) runtime
    - name: registry.redhat.io/rhaii/vllm-cuda-rhel9:3.4.1
```

> If NFD and the GPU Operator are already installed in your enclave cluster,
> remove the `operators` section and mirror only the vLLM image.

Run the mirror:

```bash
oc-mirror --config imageset-config.yaml \
  file:///path/to/output-directory
```

This produces a tar archive you can transport into the enclave.

### Load into the enclave registry

On the disconnected side:

```bash
oc-mirror --from /path/to/output-directory \
  docker://mirror.enclave.local:5000
```

---

## Step 2: Transport the Model Weights

Since you want the model as its own reusable artifact (not embedded in the vLLM
container), there are two approaches. **Both keep the model separate** so it can
be loaded into other serving runtimes.

### Option A: PVC-Based (Recommended for maximum flexibility)

This is the simplest approach and works with any serving runtime that can mount a
volume.

#### On the connected side

Download the model weights from
[openai/gpt-oss-120b on HuggingFace](https://huggingface.co/openai/gpt-oss-120b).
The model is Apache 2.0 licensed (no access request required). It is a
Mixture-of-Experts architecture (117B total parameters, 5.1B active) with MXFP4
quantized weights.

```bash
# Download the original model weights
hf download openai/gpt-oss-120b --include "original/*" --local-dir gpt-oss-120b/

# Create a tar archive for transport
tar -cf gpt-oss-120b-weights.tar -C ./gpt-oss-120b .
```

#### In the enclave

1. Create a PersistentVolumeClaim to hold the model:

```yaml
# pvc-gpt-oss-120b.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: gpt-oss-120b-weights
  namespace: ai-inference
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      # gpt-oss-120b uses MXFP4 quantized MoE weights (~70-80 GB on disk)
      # Include headroom for tokenizer, config, and original/ directory
      storage: 150Gi
  storageClassName: gp3-csi   # adjust to your cluster's storage class
```

2. Load the model weights onto the PVC:

```bash
# Apply the PVC
oc apply -f pvc-gpt-oss-120b.yaml

# Start a temporary pod to copy data into the PVC
oc run model-loader --image=registry.access.redhat.com/ubi9/ubi-minimal:latest \
  --restart=Never \
  --overrides='{
    "spec": {
      "containers": [{
        "name": "model-loader",
        "image": "registry.access.redhat.com/ubi9/ubi-minimal:latest",
        "command": ["sleep", "infinity"],
        "volumeMounts": [{
          "name": "model-volume",
          "mountPath": "/models"
        }]
      }],
      "volumes": [{
        "name": "model-volume",
        "persistentVolumeClaim": {
          "claimName": "gpt-oss-120b-weights"
        }
      }]
    }
  }'

# Wait for the pod to be ready
oc wait --for=condition=Ready pod/model-loader --timeout=120s

# Copy the model archive into the PVC and extract
oc cp gpt-oss-120b-weights.tar model-loader:/models/gpt-oss-120b-weights.tar
oc exec model-loader -- tar -xf /models/gpt-oss-120b-weights.tar -C /models
oc exec model-loader -- rm /models/gpt-oss-120b-weights.tar

# Clean up the loader pod
oc delete pod model-loader
```

### Option B: OCI ModelCar (model as an OCI container image)

This packages the model as an OCI-compliant container image ("modelcar") that
lives in your container registry. The model is loaded into the vLLM pod via an
init container that copies the weights into a shared `emptyDir` volume.

#### On the connected side, build the modelcar

```bash
# Create a Containerfile for the model
cat > Containerfile.gpt-oss-120b <<'EOF'
FROM scratch
COPY gpt-oss-120b/ /models/gpt-oss-120b
EOF

# Build and push to a staging registry (or save as tar)
podman build -t gpt-oss-120b-modelcar:latest -f Containerfile.gpt-oss-120b .

# Save to a tar archive for sneakernet transport
podman save gpt-oss-120b-modelcar:latest -o gpt-oss-120b-modelcar.tar
```

#### In the enclave

```bash
# Load into the enclave mirror registry
podman load -i gpt-oss-120b-modelcar.tar
podman tag gpt-oss-120b-modelcar:latest \
  mirror.enclave.local:5000/models/gpt-oss-120b-modelcar:latest
podman push mirror.enclave.local:5000/models/gpt-oss-120b-modelcar:latest
```

---

## Step 3: Deploy vLLM on OpenShift

### Option A: Deployment with PVC-mounted model

```yaml
# vllm-gpt-oss-120b.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ai-inference
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: vllm-server
  namespace: ai-inference
automountServiceAccountToken: false
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vllm-gpt-oss-120b
  namespace: ai-inference
  labels:
    app: vllm-gpt-oss-120b
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vllm-gpt-oss-120b
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: vllm-gpt-oss-120b
    spec:
      serviceAccountName: vllm-server
      automountServiceAccountToken: false
      securityContext:
        runAsNonRoot: true
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: vllm
          # In a disconnected cluster with ImageContentSourcePolicy / IDMS,
          # this resolves to mirror.enclave.local:5000/rhaii/vllm-cuda-rhel9:3.4.1
          image: registry.redhat.io/rhaii/vllm-cuda-rhel9:3.4.1
          args:
            - "--model"
            - "/models/gpt-oss-120b"
            - "--host"
            - "0.0.0.0"
            - "--port"
            - "8000"
            # gpt-oss-120b is a MoE model (117B total, 5.1B active) with
            # MXFP4 quantized weights -- fits on a single 80 GB GPU.
            # Increase tensor-parallel-size if using multiple GPUs for throughput.
            - "--tensor-parallel-size"
            - "1"
            - "--gpu-memory-utilization"
            - "0.90"
            # Fully disconnected -- no HuggingFace Hub calls
            - "--trust-remote-code"
          env:
            - name: HF_HUB_OFFLINE
              value: "1"
            - name: TRANSFORMERS_OFFLINE
              value: "1"
            - name: HF_HOME
              value: "/tmp/hf-home"
          ports:
            - name: http
              containerPort: 8000
              protocol: TCP
          resources:
            requests:
              cpu: "4"
              memory: 32Gi
              nvidia.com/gpu: "1"
            limits:
              cpu: "8"
              memory: 64Gi
              nvidia.com/gpu: "1"
          volumeMounts:
            - name: model-weights
              mountPath: /models
              readOnly: true
            - name: shm
              mountPath: /dev/shm
            - name: tmp
              mountPath: /tmp
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - ALL
          readinessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 120
            periodSeconds: 10
            timeoutSeconds: 5
          livenessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 180
            periodSeconds: 30
            timeoutSeconds: 10
      volumes:
        - name: model-weights
          persistentVolumeClaim:
            claimName: gpt-oss-120b-weights
        # vLLM uses shared memory for NCCL communication between GPUs
        - name: shm
          emptyDir:
            medium: Memory
            sizeLimit: 16Gi
        - name: tmp
          emptyDir: {}
      tolerations:
        - key: nvidia.com/gpu
          operator: Exists
          effect: NoSchedule
---
apiVersion: v1
kind: Service
metadata:
  name: vllm-gpt-oss-120b
  namespace: ai-inference
  labels:
    app: vllm-gpt-oss-120b
spec:
  ports:
    - name: http
      port: 8000
      protocol: TCP
      targetPort: 8000
  selector:
    app: vllm-gpt-oss-120b
  type: ClusterIP
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: vllm-gpt-oss-120b
  namespace: ai-inference
  labels:
    app: vllm-gpt-oss-120b
spec:
  port:
    targetPort: http
  to:
    kind: Service
    name: vllm-gpt-oss-120b
    weight: 100
  tls:
    termination: edge
    insecureEdgeTerminationPolicy: Redirect
```

### Option B: Deployment with OCI ModelCar init container

If you packaged the model as a modelcar OCI image, use an init container to copy
the weights into a shared `emptyDir` volume at pod startup.

```yaml
# vllm-gpt-oss-120b-modelcar.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ai-inference
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: vllm-server
  namespace: ai-inference
automountServiceAccountToken: false
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vllm-gpt-oss-120b
  namespace: ai-inference
  labels:
    app: vllm-gpt-oss-120b
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vllm-gpt-oss-120b
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: vllm-gpt-oss-120b
    spec:
      serviceAccountName: vllm-server
      automountServiceAccountToken: false
      securityContext:
        runAsNonRoot: true
        seccompProfile:
          type: RuntimeDefault
      initContainers:
        - name: model-loader
          # The modelcar image you pushed to the enclave mirror registry
          image: mirror.enclave.local:5000/models/gpt-oss-120b-modelcar:latest
          command: ["cp", "-r", "/models/gpt-oss-120b", "/shared-models/"]
          volumeMounts:
            - name: model-volume
              mountPath: /shared-models
          resources:
            requests:
              cpu: "1"
              memory: 4Gi
            limits:
              cpu: "2"
              memory: 8Gi
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - ALL
      containers:
        - name: vllm
          image: registry.redhat.io/rhaii/vllm-cuda-rhel9:3.4.1
          args:
            - "--model"
            - "/models/gpt-oss-120b"
            - "--host"
            - "0.0.0.0"
            - "--port"
            - "8000"
            - "--tensor-parallel-size"
            - "1"
            - "--gpu-memory-utilization"
            - "0.90"
            - "--trust-remote-code"
          env:
            - name: HF_HUB_OFFLINE
              value: "1"
            - name: TRANSFORMERS_OFFLINE
              value: "1"
            - name: HF_HOME
              value: "/tmp/hf-home"
          ports:
            - name: http
              containerPort: 8000
              protocol: TCP
          resources:
            requests:
              cpu: "4"
              memory: 32Gi
              nvidia.com/gpu: "1"
            limits:
              cpu: "8"
              memory: 64Gi
              nvidia.com/gpu: "1"
          volumeMounts:
            - name: model-volume
              mountPath: /models
              readOnly: true
            - name: shm
              mountPath: /dev/shm
            - name: tmp
              mountPath: /tmp
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - ALL
          readinessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 120
            periodSeconds: 10
            timeoutSeconds: 5
          livenessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 180
            periodSeconds: 30
            timeoutSeconds: 10
      volumes:
        - name: model-volume
          emptyDir:
            sizeLimit: 150Gi
        - name: shm
          emptyDir:
            medium: Memory
            sizeLimit: 16Gi
        - name: tmp
          emptyDir: {}
      tolerations:
        - key: nvidia.com/gpu
          operator: Exists
          effect: NoSchedule
---
apiVersion: v1
kind: Service
metadata:
  name: vllm-gpt-oss-120b
  namespace: ai-inference
  labels:
    app: vllm-gpt-oss-120b
spec:
  ports:
    - name: http
      port: 8000
      protocol: TCP
      targetPort: 8000
  selector:
    app: vllm-gpt-oss-120b
  type: ClusterIP
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: vllm-gpt-oss-120b
  namespace: ai-inference
  labels:
    app: vllm-gpt-oss-120b
spec:
  port:
    targetPort: http
  to:
    kind: Service
    name: vllm-gpt-oss-120b
    weight: 100
  tls:
    termination: edge
    insecureEdgeTerminationPolicy: Redirect
```

---

## Step 4: Configure Image Mirroring in the Cluster

Create an `ImageDigestMirrorSet` (IDMS) or `ImageContentSourcePolicy` (ICSP) so
the cluster resolves `registry.redhat.io` references to your enclave mirror:

```yaml
# idms-rhaii.yaml
apiVersion: config.openshift.io/v1
kind: ImageDigestMirrorSet
metadata:
  name: rhaii-mirror
spec:
  imageDigestMirrors:
    - source: registry.redhat.io/rhaii
      mirrors:
        - mirror.enclave.local:5000/rhaii
    - source: registry.redhat.io/redhat
      mirrors:
        - mirror.enclave.local:5000/redhat
    - source: registry.redhat.io/nvidia
      mirrors:
        - mirror.enclave.local:5000/nvidia
```

```bash
oc apply -f idms-rhaii.yaml
```

---

## Step 5: Deploy

```bash
# Create the namespace
oc new-project ai-inference || true

# If using PVC approach (Option A):
oc apply -f pvc-gpt-oss-120b.yaml
# ... load model weights per Step 2, Option A ...
oc apply -f vllm-gpt-oss-120b.yaml

# If using ModelCar approach (Option B):
oc apply -f vllm-gpt-oss-120b-modelcar.yaml

# Watch the rollout
oc rollout status deployment/vllm-gpt-oss-120b -n ai-inference --timeout=600s
```

---

## Step 6: Verify

```bash
# Check the pod is running and GPUs are allocated
oc get pods -n ai-inference -o wide
oc describe pod -l app=vllm-gpt-oss-120b -n ai-inference | grep -A5 "nvidia.com/gpu"

# Check logs for successful model load
oc logs -f deployment/vllm-gpt-oss-120b -n ai-inference

# Test the OpenAI-compatible API
ROUTE=$(oc get route vllm-gpt-oss-120b -n ai-inference -o jsonpath='{.spec.host}')

curl -sk "https://${ROUTE}/v1/models" | python3 -m json.tool

curl -sk "https://${ROUTE}/v1/completions" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-oss-120b",
    "prompt": "Hello, how are you?",
    "max_tokens": 50
  }'
```

---

## Complete Image Mirror List

For reference, here is the consolidated list of all container images that need to
be mirrored for transport into the enclave:

```
# Red Hat AI Inference (vLLM) runtime
registry.redhat.io/rhaii/vllm-cuda-rhel9:3.4.1

# Operator catalogs (match tag to your OCP version)
registry.redhat.io/redhat/redhat-operator-index:v4.17
registry.redhat.io/redhat/certified-operator-index:v4.17

# Model loader utility (only needed for PVC loading)
registry.access.redhat.com/ubi9/ubi-minimal:latest
```

> The NFD and NVIDIA GPU Operator images are pulled automatically from the
> mirrored operator catalogs. If those operators are already installed, you only
> need the vLLM runtime image.

---

## GPU Sizing Reference

gpt-oss-120b is a Mixture-of-Experts (MoE) model with 117B total parameters but
only 5.1B active parameters per forward pass. The weights ship in MXFP4
quantization, so the model fits on a single 80 GB GPU.

| Configuration | GPUs Required | Notes |
|---|---|---|
| MXFP4 (default weights) | 1x H100 80 GB | Recommended -- native quantization format |
| MXFP4 (default weights) | 1x A100 80 GB | Supported, fits within 80 GB VRAM |
| Multi-GPU (throughput) | 2-4x H100/A100 80 GB | Use `--tensor-parallel-size 2` or `4` for higher throughput |
| AMD MI300X | 1x MI300X | Use `vllm-rocm-rhel9` image instead |

Adjust `--tensor-parallel-size` and `nvidia.com/gpu` resource requests to match
your hardware. For multi-GPU throughput scaling, set `tensor-parallel-size` to
match the GPU count.

---

## Key vLLM Arguments for Disconnected Use

| Argument | Value | Purpose |
|---|---|---|
| `--model` | `/models/gpt-oss-120b` | Path to local model weights (not a HuggingFace repo ID) |
| `--tensor-parallel-size` | `1` | Number of GPUs (increase for throughput scaling) |
| `--gpu-memory-utilization` | `0.90` | Use 90% of available GPU memory |
| `--trust-remote-code` | (flag) | Allow custom model code bundled with weights |
| `HF_HUB_OFFLINE=1` | env var | Prevent any HuggingFace Hub network calls |
| `TRANSFORMERS_OFFLINE=1` | env var | Prevent transformers library network calls |

---

## Reusing the Model with Other Runtimes

Because the model weights are stored separately (on a PVC or as a modelcar OCI
image), you can mount them into other serving runtimes:

- **OpenShift AI (KServe):** Mount the same PVC or reference the modelcar image
  in an `InferenceService` or `LLMInferenceService` resource.
- **NVIDIA Triton:** Mount the PVC at the Triton model repository path.
- **Text Generation Inference (TGI):** Mount the PVC and point `--model-id` to
  the mount path.
- **Custom runtimes:** Any container that can read HuggingFace-format model
  weights from a volume mount.

---

## References

- [openai/gpt-oss-120b on HuggingFace](https://huggingface.co/openai/gpt-oss-120b) -- model card, download instructions, and license
- [Deploy standalone Red Hat AI Inference in a disconnected environment (3.4)](https://access.redhat.com/documentation/en-us/red_hat_ai_inference/3.4/html-single/deploy_the_standalone_red_hat_ai_inference_container_in_a_disconnected_environment/index)
- [Deploy standalone Red Hat AI Inference in OpenShift (3.4)](https://access.redhat.com/documentation/en-us/red_hat_ai_inference/3.4/html-single/deploy_the_standalone_red_hat_ai_inference_container_in_openshift_container_platform/index)
- [OCI-compliant model containers / ModelCar (3.4)](https://access.redhat.com/documentation/en-us/red_hat_ai_inference/3.4/html-single/inference_serving_language_models_in_oci-compliant_model_containers/index)
- [vLLM server arguments (3.4)](https://access.redhat.com/documentation/en-us/red_hat_ai_inference/3.4/html-single/vllm_server_arguments/index)
- [Red Hat AI Inference 3.4 Release Notes](https://access.redhat.com/documentation/en-us/red_hat_ai_inference/3.4/html-single/release_notes/index)
