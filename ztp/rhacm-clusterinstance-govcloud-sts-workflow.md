# Deploying OpenShift Clusters on AWS GovCloud with STS Using RHACM and the ClusterInstance CR

This workflow covers deploying OpenShift 4.20 clusters to AWS GovCloud (US) using AWS Security Token Service (STS) short-term credentials, provisioned through Red Hat Advanced Cluster Management (RHACM) with the SiteConfig operator and the `ClusterInstance` custom resource.

All steps assume a **disconnected (air-gapped)** hub cluster environment.

> **Note:** The `SiteConfig` CR is deprecated. This workflow uses the `ClusterInstance` CR (`siteconfig.open-cluster-management.io/v1alpha1`) exclusively.

## Architecture

```
                           Disconnected Hub Cluster (RHACM)
                          ┌─────────────────────────────────────────────┐
                          │                                             │
                          │  MultiClusterHub (SiteConfig enabled)       │
                          │       │                                     │
                          │       ▼                                     │
  ccoctl (workstation)    │  SiteConfig Operator                        │
       │                  │       │                                     │
       ▼                  │       ▼                                     │
  AWS GovCloud IAM        │  ClusterInstance CR                         │
  ├─ OIDC Provider        │   ├─ extraManifestsRefs ──► STS ConfigMaps │
  ├─ IAM Roles            │   ├─ installConfigOverrides (GovCloud)     │
  ├─ S3 Bucket (private)  │   └─ templateRefs (cluster/node templates) │
  └─ Trust Policies       │       │                                     │
       │                  │       ▼                                     │
       ▼                  │  Generated Resources                        │
  Manifests + TLS keys    │   ├─ ClusterDeployment                     │
       │                  │   ├─ AgentClusterInstall                   │
       ▼                  │   ├─ InfraEnv                              │
  Package as ConfigMaps ──┤   ├─ ManagedCluster                        │
  on hub cluster          │   └─ Credential Secrets (STS)              │
                          │       │                                     │
                          │       ▼                                     │
                          │  Spoke Cluster (AWS GovCloud)               │
                          │   └─ OCP 4.20 with STS (manual mode CCO)   │
                          └─────────────────────────────────────────────┘
```

## Prerequisites

| Requirement | Details |
|-------------|---------|
| **Hub cluster** | OpenShift 4.17+ with RHACM 2.12+ (includes multicluster engine 2.7+) |
| **Hub environment** | Disconnected — mirror registry accessible from hub, no internet |
| **Workstation** | Internet-connected (or with access to AWS GovCloud APIs) for ccoctl |
| **AWS GovCloud account** | IAM permissions to create OIDC providers, IAM roles, S3 buckets |
| **AWS GovCloud region** | `us-gov-west-1` or `us-gov-east-1` |
| **Tools** | `oc` (hub access), `ccoctl` (matching OCP version), `aws` CLI (configured for GovCloud) |
| **Mirror registry** | OCP release images, MCE/RHACM operator images mirrored |
| **OCP release image** | 4.20.x mirrored to disconnected registry |

---

## Phase 1: Enable the SiteConfig Operator (Disconnected)

### 1.1 Mirror Required Images

In a disconnected environment, the SiteConfig operator images are included as part of the multicluster engine (MCE) operator. Ensure the following are mirrored to your disconnected registry:

```bash
# Mirror the MCE operator images (includes SiteConfig operator)
# These should already be mirrored if RHACM is installed in disconnected mode.
# Verify with:
oc get pods -n open-cluster-management | grep siteconfig
```

If MCE images are not yet mirrored, use `oc-mirror` to mirror the `multicluster-engine` operator catalog:

```bash
# ImageSetConfiguration for oc-mirror (example)
cat <<'EOF' > imageset-config.yaml
apiVersion: mirror.openshift.io/v2alpha1
kind: ImageSetConfiguration
mirror:
  operators:
    - catalog: registry.redhat.io/redhat/redhat-operator-index:v4.20
      packages:
        - name: multicluster-engine
        - name: advanced-cluster-management
  additionalImages:
    - name: registry.redhat.io/rhacm2/siteconfig-operator-rhel9:v2.12
EOF

oc-mirror --config=imageset-config.yaml \
  docker://<mirror-registry>:<port>
```

Create the ImageDigestMirrorSet (IDMS) for the mirrored content:

```yaml
apiVersion: config.openshift.io/v1
kind: ImageDigestMirrorSet
metadata:
  name: rhacm-mirror
spec:
  imageDigestMirrors:
    - source: registry.redhat.io
      mirrors:
        - <mirror-registry>:<port>/registry-redhat-io
    - source: quay.io/openshift-release-dev/ocp-release
      mirrors:
        - <mirror-registry>:<port>/openshift/release-images
    - source: quay.io/openshift-release-dev/ocp-v4.0-art-dev
      mirrors:
        - <mirror-registry>:<port>/openshift/release
```

### 1.2 Enable the SiteConfig Component on MultiClusterHub

Patch the MultiClusterHub to enable the SiteConfig component:

```bash
export MCH_NAMESPACE=open-cluster-management

oc patch multiclusterhubs.operator.open-cluster-management.io multiclusterhub \
  -n ${MCH_NAMESPACE} \
  --type json \
  --patch '[{"op": "add", "path":"/spec/overrides/components/-", "value": {"name":"siteconfig","enabled": true}}]'
```

Verify the SiteConfig operator pod is running:

```bash
oc -n ${MCH_NAMESPACE} get pods | grep siteconfig
```

Expected output:

```
siteconfig-controller-manager-<hash>   2/2     Running   0   1m
```

### 1.3 Create the AgentServiceConfig

The AgentServiceConfig enables the Assisted Installer on the hub. For disconnected environments, include `osImages` pointing to locally hosted RHCOS images.

```bash
# Download RHCOS ISO to a local HTTP server (from a connected system)
curl -O https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/4.20/latest/rhcos-live.x86_64.iso
# Copy to your disconnected HTTP server
scp rhcos-live.x86_64.iso <http-server>:/var/www/html/rhcos/
```

```yaml
apiVersion: agent-install.openshift.io/v1beta1
kind: AgentServiceConfig
metadata:
  name: agent
spec:
  databaseStorage:
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: 4Gi
  filesystemStorage:
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: 100Gi
  imageStorage:
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: 50Gi
  # Disconnected: mirror registry trust and RHCOS images
  mirrorRegistryRef:
    name: mirror-registry-config      # ConfigMap with registries.conf + CA
  osImages:
    - openshiftVersion: '4.20'
      version: '420.86.202301311551-0'
      cpuArchitecture: x86_64
      url: 'https://<http-server>/rhcos/rhcos-live.x86_64.iso'
```

```bash
oc create -f agent-service-config.yaml
```

### 1.4 Create the Provisioning CR

```yaml
apiVersion: metal3.io/v1alpha1
kind: Provisioning
metadata:
  name: metal3-provisioning
spec:
  provisioningNetwork: Disabled
  virtualMediaViaExternalNetwork: true
  watchAllNamespaces: true
```

```bash
oc create -f provisioning.yaml
```

### 1.5 Configure RBAC

Grant subscription-admin privileges for RHACM cluster provisioning:

```bash
oc adm policy add-cluster-role-to-user \
  --rolebinding-name=open-cluster-management:subscription-admin \
  open-cluster-management:subscription-admin kube:admin

oc adm policy add-cluster-role-to-user \
  --rolebinding-name=open-cluster-management:subscription-admin \
  open-cluster-management:subscription-admin system:admin
```

### 1.6 Verify SiteConfig Operator is Ready

```bash
# Check the operator pod
oc -n open-cluster-management get pods | grep siteconfig

# Check CRDs are registered
oc get crd clusterinstances.siteconfig.open-cluster-management.io

# Check the default templates are available
oc get configmaps -n open-cluster-management | grep templates
```

---

## Phase 2: Pre-create AWS STS Resources with ccoctl

These steps run on an **internet-connected workstation** (or a bastion with access to AWS GovCloud APIs). The outputs are then transferred to the disconnected hub.

### 2.1 Configure AWS GovCloud Credentials

```bash
export AWS_ACCESS_KEY_ID='<your-govcloud-access-key>'
export AWS_SECRET_ACCESS_KEY='<your-govcloud-secret-key>'
export AWS_DEFAULT_REGION='us-gov-west-1'
```

### 2.2 Extract the ccoctl Binary

Extract `ccoctl` from the OCP release image matching your target version:

```bash
# From a connected environment
RELEASE_IMAGE="quay.io/openshift-release-dev/ocp-release:4.20.15-x86_64"

# Extract ccoctl
oc adm release extract \
  --credentials-requests-dir=/dev/null \
  --command=ccoctl \
  --from=${RELEASE_IMAGE} \
  --to=.

chmod +x ccoctl
```

For disconnected environments, extract from the mirrored release image:

```bash
RELEASE_IMAGE="<mirror-registry>:<port>/openshift/release-images:4.20.15-x86_64"

oc adm release extract \
  --command=ccoctl \
  --from=${RELEASE_IMAGE} \
  --to=.
```

### 2.3 Extract CredentialsRequest Objects

Extract the CredentialsRequest manifests from the release image. These define the IAM roles needed by each OCP component.

```bash
mkdir -p credreqs ccoctl-output

# From connected environment
oc adm release extract \
  --credentials-requests \
  --cloud=aws \
  --from=${RELEASE_IMAGE} \
  --to=credreqs/

# Verify extraction
ls credreqs/
```

You should see files like:

```
0000_26_cloud-controller-manager-operator_18_credentialsrequest-aws.yaml
0000_30_machine-api-operator_00_credentials-request.yaml
0000_50_cloud-credential-operator_05-iam-ro-credentialsrequest.yaml
0000_50_cluster-image-registry-operator_01-registry-credentials-request-aws.yaml
0000_50_cluster-ingress-operator_00-ingress-credentials-request.yaml
0000_50_cluster-network-operator_02-cncc-credentials.yaml
0000_50_cluster-storage-operator_03_credentials_request_aws.yaml
```

### 2.4 Run ccoctl to Create AWS Resources

> **GovCloud requires `--create-private-s3-bucket`** — CloudFront is not available in AWS GovCloud regions. The `--create-private-s3-bucket` flag creates the OIDC S3 bucket with direct S3 URL access instead of CloudFront distribution.

```bash
CLUSTER_NAME="govcloud-spoke1"

./ccoctl aws create-all \
  --name=${CLUSTER_NAME} \
  --region=${AWS_DEFAULT_REGION} \
  --credentials-requests-dir=credreqs/ \
  --output-dir=ccoctl-output/ \
  --create-private-s3-bucket
```

### 2.5 Understand the ccoctl Output

After successful execution, `ccoctl-output/` contains:

```
ccoctl-output/
├── manifests/
│   ├── cluster-authentication-02-config.yaml    # Authentication CR (OIDC issuer URL)
│   ├── openshift-cloud-controller-manager-aws-cloud-credentials-credentials.yaml
│   ├── openshift-cloud-credential-operator-cloud-credential-operator-iam-ro-creds-credentials.yaml
│   ├── openshift-cluster-csi-drivers-ebs-cloud-credentials-credentials.yaml
│   ├── openshift-image-registry-installer-cloud-credentials-credentials.yaml
│   ├── openshift-ingress-operator-cloud-credentials-credentials.yaml
│   ├── openshift-machine-api-aws-cloud-credentials-credentials.yaml
│   └── openshift-cloud-network-config-controller-cloud-credentials-credentials.yaml
├── tls/
│   └── bound-service-account-signing-key.key    # SA signing key
├── serviceaccount-signer.private                # RSA private key
└── serviceaccount-signer.public                 # RSA public key
```

**Key files:**
- `manifests/cluster-authentication-02-config.yaml` — Sets the OIDC issuer URL on the cluster's Authentication CR
- `manifests/*-credentials.yaml` — Secret manifests containing IAM role ARNs for each OCP component
- `tls/bound-service-account-signing-key.key` — Service account signing key used by the kube-apiserver

### 2.6 Block Public Access to the OIDC S3 Bucket

For GovCloud security compliance, ensure the OIDC bucket has public access blocked:

```bash
aws s3api put-public-access-block \
  --bucket ${CLUSTER_NAME}-oidc \
  --public-access-block-configuration '{
    "BlockPublicAcls": true,
    "IgnorePublicAcls": true,
    "BlockPublicPolicy": true,
    "RestrictPublicBuckets": true
  }'
```

### 2.7 Transfer ccoctl Output to Disconnected Environment

Copy the entire `ccoctl-output/` directory to the disconnected hub environment:

```bash
# From the connected workstation
tar czf ccoctl-output.tar.gz ccoctl-output/
scp ccoctl-output.tar.gz <bastion>:/path/to/transfer/

# On the disconnected hub bastion
tar xzf ccoctl-output.tar.gz
```

---

## Phase 3: Package STS Resources as Kubernetes ConfigMaps

The STS resources from ccoctl must be packaged as ConfigMaps on the hub cluster so the `ClusterInstance` CR can reference them via `extraManifestsRefs`.

### 3.1 Create the Cluster Namespace

```bash
CLUSTER_NAME="govcloud-spoke1"
CLUSTER_NAMESPACE="${CLUSTER_NAME}"

oc create namespace ${CLUSTER_NAMESPACE}
```

### 3.2 Create the STS Credential Secrets ConfigMap

Package all the credential Secret manifests from `ccoctl-output/manifests/` into a single ConfigMap. Each credential file becomes a key in the ConfigMap.

```bash
# Create a ConfigMap containing all STS credential secrets
oc create configmap sts-credential-manifests \
  -n ${CLUSTER_NAMESPACE} \
  --from-file=ccoctl-output/manifests/
```

Verify the ConfigMap contains all expected keys:

```bash
oc get configmap sts-credential-manifests -n ${CLUSTER_NAMESPACE} -o jsonpath='{.data}' | jq 'keys'
```

Alternatively, create the ConfigMap with explicit YAML for more control:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: sts-credential-manifests
  namespace: govcloud-spoke1
data:
  cluster-authentication-02-config.yaml: |
    apiVersion: config.openshift.io/v1
    kind: Authentication
    metadata:
      name: cluster
    spec:
      serviceAccountIssuer: https://s3.us-gov-west-1.amazonaws.com/govcloud-spoke1-oidc
  openshift-cloud-controller-manager-credentials.yaml: |
    apiVersion: v1
    kind: Secret
    metadata:
      name: aws-cloud-credentials
      namespace: openshift-cloud-controller-manager
    stringData:
      credentials: |
        [default]
        role_arn = arn:aws-us-gov:iam::<account-id>:role/govcloud-spoke1-openshift-cloud-controller-manager-aws-cloud-credentials
        web_identity_token_file = /var/run/secrets/openshift/serviceaccount/token
  # ... (one entry per credential file from ccoctl-output/manifests/)
```

### 3.3 Create the TLS Signing Key ConfigMap

Package the service account signing key:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: sts-tls-signing-key
  namespace: govcloud-spoke1
data:
  bound-service-account-signing-key.key: |
    <contents of ccoctl-output/tls/bound-service-account-signing-key.key>
```

```bash
oc create configmap sts-tls-signing-key \
  -n ${CLUSTER_NAMESPACE} \
  --from-file=ccoctl-output/tls/bound-service-account-signing-key.key
```

### 3.4 Verify ConfigMaps

```bash
oc get configmaps -n ${CLUSTER_NAMESPACE}
```

Expected:

```
NAME                       DATA   AGE
sts-credential-manifests   8      1m
sts-tls-signing-key        1      1m
```

---

## Phase 4: Create the ClusterInstance CR for AWS GovCloud

### 4.1 Create Supporting Resources

#### Pull Secret

```bash
oc create secret generic pull-secret \
  -n ${CLUSTER_NAMESPACE} \
  --from-file=.dockerconfigjson=<path-to-pull-secret.json> \
  --type=kubernetes.io/dockerconfigjson
```

For disconnected environments, the pull secret must include credentials for your mirror registry.

#### SSH Key

```bash
oc create secret generic ssh-key \
  -n ${CLUSTER_NAMESPACE} \
  --from-file=ssh-publickey=$HOME/.ssh/id_rsa.pub
```

#### ClusterImageSet

Point to the mirrored release image:

```yaml
apiVersion: hive.openshift.io/v1
kind: ClusterImageSet
metadata:
  name: img4.20.15-x86-64
spec:
  releaseImage: <mirror-registry>:<port>/openshift/release-images:4.20.15-x86_64
```

```bash
oc create -f cluster-image-set.yaml
```

#### Mirror Registry CA ConfigMap (Disconnected)

If your mirror registry uses a self-signed CA:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mirror-registry-ca
  namespace: govcloud-spoke1
data:
  ca-bundle.crt: |
    -----BEGIN CERTIFICATE-----
    <your mirror registry CA certificate>
    -----END CERTIFICATE-----
```

#### IDMS Extra Manifest ConfigMap (Disconnected)

Create a ConfigMap containing the ImageDigestMirrorSet for the spoke cluster:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: idms-extra-manifest
  namespace: govcloud-spoke1
data:
  idms.yaml: |
    apiVersion: config.openshift.io/v1
    kind: ImageDigestMirrorSet
    metadata:
      name: release-mirror
    spec:
      imageDigestMirrors:
        - source: quay.io/openshift-release-dev/ocp-release
          mirrors:
            - <mirror-registry>:<port>/openshift/release-images
        - source: quay.io/openshift-release-dev/ocp-v4.0-art-dev
          mirrors:
            - <mirror-registry>:<port>/openshift/release
        - source: registry.redhat.io
          mirrors:
            - <mirror-registry>:<port>/registry-redhat-io
```

### 4.2 Create the ClusterInstance CR

> **Platform note:** The SiteConfig operator and ClusterInstance CR are primarily designed for bare-metal and edge deployments using the Assisted Installer. For AWS IPI provisioning, you may need custom cluster and node templates that generate the appropriate Hive ClusterDeployment resources instead of the default Assisted Installer resources. Consult the RHACM documentation on creating custom installation templates for your platform.

The following ClusterInstance CR uses `extraManifestsRefs` to inject the STS resources and `installConfigOverrides` to configure the AWS GovCloud platform settings.

```yaml
---
apiVersion: siteconfig.open-cluster-management.io/v1alpha1
kind: ClusterInstance
metadata:
  name: govcloud-spoke1
  namespace: govcloud-spoke1
spec:
  clusterName: govcloud-spoke1
  baseDomain: example.openshiftusgov.com
  clusterImageSetNameRef: img4.20.15-x86-64
  clusterType: HighlyAvailable
  cpuArchitecture: x86_64

  # --- STS Extra Manifests ---
  # These ConfigMaps contain the STS credential secrets, Authentication CR,
  # and TLS signing key generated by ccoctl in Phase 2.
  extraManifestsRefs:
    - name: sts-credential-manifests
    - name: sts-tls-signing-key
    - name: idms-extra-manifest           # Disconnected: mirror config for spoke

  # --- Install Config Overrides ---
  # Set credentialsMode to Manual for STS and configure AWS GovCloud platform.
  installConfigOverrides: |
    {
      "credentialsMode": "Manual",
      "platform": {
        "aws": {
          "region": "us-gov-west-1",
          "propagateUserTags": true
        }
      },
      "publish": "Internal",
      "fips": false,
      "additionalTrustBundlePolicy": "Always"
    }

  # --- Networking ---
  clusterNetwork:
    - cidr: 10.128.0.0/14
      hostPrefix: 23
  serviceNetwork:
    - cidr: 172.30.0.0/16
  machineNetwork:
    - cidr: 10.0.0.0/24
  networkType: OVNKubernetes

  # --- Disconnected Mirror CA ---
  caBundleRef:
    name: mirror-registry-ca

  # --- Credentials ---
  pullSecretRef:
    name: pull-secret
  sshPublicKey: 'ssh-rsa AAAA...'

  # --- Templates ---
  # Use the default Assisted Installer templates, or custom templates for AWS.
  templateRefs:
    - name: ai-cluster-templates-v1
      namespace: open-cluster-management

  # --- Nodes ---
  # For AWS, node definitions depend on your template approach.
  # With Assisted Installer templates, define physical/virtual nodes.
  # With custom AWS templates, node definitions map to EC2 instance config.
  nodes:
    - hostName: master-0.govcloud-spoke1.example.openshiftusgov.com
      role: master
      bmcAddress: ""                       # Platform-specific; empty for cloud
      bmcCredentialsName:
        name: ""
      bootMACAddress: ""
      templateRefs:
        - name: ai-node-templates-v1
          namespace: open-cluster-management
    - hostName: master-1.govcloud-spoke1.example.openshiftusgov.com
      role: master
      bmcAddress: ""
      bmcCredentialsName:
        name: ""
      bootMACAddress: ""
      templateRefs:
        - name: ai-node-templates-v1
          namespace: open-cluster-management
    - hostName: master-2.govcloud-spoke1.example.openshiftusgov.com
      role: master
      bmcAddress: ""
      bmcCredentialsName:
        name: ""
      bootMACAddress: ""
      templateRefs:
        - name: ai-node-templates-v1
          namespace: open-cluster-management
```

### 4.3 ClusterInstance Fields Reference

| Field | Purpose |
|-------|---------|
| `extraManifestsRefs` | References ConfigMaps containing additional manifests injected at install time (STS secrets, IDMS, etc.) |
| `installConfigOverrides` | JSON patch applied to the generated `install-config.yaml` — use for `credentialsMode`, platform config, publish mode |
| `caBundleRef` | Reference to a ConfigMap containing the CA trust bundle for the mirror registry |
| `clusterImageSetNameRef` | Name of the ClusterImageSet pointing to the (mirrored) OCP release image |
| `templateRefs` | References to cluster-level installation templates |
| `nodes[].templateRefs` | References to node-level installation templates |

---

## Phase 5: Deploy and Monitor

### 5.1 Apply Resources in Order

```bash
CLUSTER_NAMESPACE="govcloud-spoke1"

# 1. Namespace (already created in Phase 3)
# oc create namespace ${CLUSTER_NAMESPACE}

# 2. Secrets and ConfigMaps
oc apply -f pull-secret.yaml
oc apply -f ssh-key.yaml
oc apply -f mirror-registry-ca.yaml

# 3. STS ConfigMaps (created in Phase 3)
# Already created: sts-credential-manifests, sts-tls-signing-key

# 4. IDMS extra manifest
oc apply -f idms-extra-manifest.yaml

# 5. ClusterImageSet (cluster-scoped)
oc apply -f cluster-image-set.yaml

# 6. ClusterInstance CR (triggers provisioning)
oc apply -f clusterinstance-govcloud-spoke1.yaml
```

### 5.2 Monitor Provisioning

```bash
# Watch the ClusterInstance status
oc get clusterinstance -n ${CLUSTER_NAMESPACE} -w

# Detailed status
oc describe clusterinstance govcloud-spoke1 -n ${CLUSTER_NAMESPACE}

# Check generated sub-resources
oc get clusterdeployment -n ${CLUSTER_NAMESPACE}
oc get agentclusterinstall -n ${CLUSTER_NAMESPACE}
oc get infraenv -n ${CLUSTER_NAMESPACE}
oc get managedcluster govcloud-spoke1

# Watch AgentClusterInstall for install progress
oc get agentclusterinstall -n ${CLUSTER_NAMESPACE} -w

# Check events for errors
oc get events -n ${CLUSTER_NAMESPACE} --sort-by='.lastTimestamp'
```

### 5.3 Verify STS is Active on the Spoke Cluster

After the spoke cluster is installed, verify STS is operational:

```bash
# Get kubeconfig for the spoke cluster
oc get secret -n ${CLUSTER_NAMESPACE} govcloud-spoke1-admin-kubeconfig \
  -o jsonpath='{.data.kubeconfig}' | base64 -d > spoke-kubeconfig

# Check CCO mode on the spoke
KUBECONFIG=spoke-kubeconfig oc get cloudcredential cluster -o jsonpath='{.spec.credentialsMode}'
# Expected: Manual

# Verify Authentication CR has the OIDC issuer
KUBECONFIG=spoke-kubeconfig oc get authentication cluster -o jsonpath='{.spec.serviceAccountIssuer}'
# Expected: https://s3.us-gov-west-1.amazonaws.com/<cluster-name>-oidc

# Check all operators are running (no credential errors)
KUBECONFIG=spoke-kubeconfig oc get co
```

---

## Troubleshooting

### ccoctl Errors

| Issue | Cause | Resolution |
|-------|-------|------------|
| `dial tcp: lookup cloudfront.us-gov-west-1.amazonaws.com: no such host` | CloudFront is not available in GovCloud | Use `--create-private-s3-bucket` flag with ccoctl |
| `AccessDenied` on S3 bucket creation | IAM user lacks `s3:CreateBucket` permission | Add S3 permissions to the IAM user in GovCloud |
| `InvalidIdentityToken` during install | OIDC provider URL mismatch or S3 bucket policy issue | Verify the `serviceAccountIssuer` in `cluster-authentication-02-config.yaml` matches the S3 bucket URL; check bucket policy allows read access from the OIDC thumbprint |

### SiteConfig Operator Errors

| Issue | Cause | Resolution |
|-------|-------|------------|
| SiteConfig pod not running | Component not enabled on MCH | Re-run the MCH patch command; verify with `oc get mch multiclusterhub -n open-cluster-management -o yaml` |
| ClusterInstance validation failure | Missing required fields or invalid template references | Check `oc describe clusterinstance <name>` for validation messages |
| `extraManifestsRefs` ConfigMap not found | ConfigMap not in the same namespace as ClusterInstance | Ensure all referenced ConfigMaps exist in the cluster namespace |

### Disconnected Environment Errors

| Issue | Cause | Resolution |
|-------|-------|------------|
| Release image pull failure | Missing IDMS or mirror CA trust | Verify ClusterImageSet points to mirror URL; check `caBundleRef` ConfigMap exists |
| `x509: certificate signed by unknown authority` | Mirror registry CA not trusted | Add CA to the AgentServiceConfig `mirrorRegistryRef` and ClusterInstance `caBundleRef` |
| RHCOS ISO download failure | Hub can't reach the osImages URL | Verify the RHCOS ISO is hosted on an HTTP server accessible from the hub |

### AWS GovCloud Specific

| Issue | Cause | Resolution |
|-------|-------|------------|
| Route53 private hosted zone loops | Known OCP issue with `openshift-install destroy` in GovCloud | See [Red Hat Solution 6974761](https://access.redhat.com/solutions/6974761) |
| STS tokens expire during long installs | Default STS token duration too short | Ensure IAM role trust policy allows sufficient session duration |
| `publish: External` fails | GovCloud does not support public Route53 zones | Set `publish: Internal` in `installConfigOverrides` |

---

## Reference

### Official Red Hat Documentation

| Topic | Link |
|-------|------|
| SiteConfig Operator Overview | [Installing single-node OpenShift clusters with the SiteConfig Operator](https://access.redhat.com/articles/7079633) |
| ClusterInstance CR (RHACM 2.12) | [multicluster engine operator with RHACM 2.12](https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/2.12/html-single/multicluster_engine_operator_with_red_hat_advanced_cluster_management/index) |
| ClusterInstance CR (RHACM 2.17) | [multicluster engine operator with RHACM 2.17](https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/2.17/html-single/multicluster_engine_operator_with_red_hat_advanced_cluster_management/index) |
| OCP 4.20 Installing on AWS (STS) | [Installing on AWS — OCP 4.20](https://access.redhat.com/documentation/en-us/openshift_container_platform/4.20/html-single/installing_on_aws/index) |
| OCP on AWS GovCloud | [Is it supported to deploy OCP in AWS GovCloud?](https://access.redhat.com/solutions/5137221) |
| AWS STS with OCP | [Cloud provider authentication on AWS without static credentials](https://access.redhat.com/solutions/4936371) |
| RHACM Clusters (AWS GovCloud) | [RHACM 2.12 Clusters — Creating on AWS GovCloud](https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/2.12/html-single/clusters/index) |
| Additional Manifests (ClusterDeployment) | [RHACM 2.6 multicluster engine — Configuring additional manifests](https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/2.6/html-single/multicluster_engine/index) |

### ClusterInstance API Reference

```
apiVersion: siteconfig.open-cluster-management.io/v1alpha1
kind: ClusterInstance
```

Key fields for STS integration:

| Field | Type | Description |
|-------|------|-------------|
| `spec.extraManifestsRefs` | `[]ObjectReference` | List of ConfigMap references containing manifests to inject during install |
| `spec.installConfigOverrides` | `string` (JSON) | JSON patch applied to the generated install-config.yaml |
| `spec.caBundleRef` | `ObjectReference` | ConfigMap with CA trust bundle for mirror registry |
| `spec.templateRefs` | `[]TemplateRef` | Cluster-level installation templates |
| `spec.nodes[].templateRefs` | `[]TemplateRef` | Node-level installation templates |
| `spec.clusterImageSetNameRef` | `string` | Name of the ClusterImageSet with the release image |
| `spec.pullSecretRef` | `ObjectReference` | Reference to the pull secret |
