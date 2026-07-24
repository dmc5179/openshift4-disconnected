# Red Hat Offline Knowledge Portal

## Obtain Access Key

- Follow the steps here to get your access key

https://docs.redhat.com/en/documentation/red_hat_offline_knowledge_portal/1/html/user_guide/proc_launching-rhokp

## Deploying the container with podman

. Run the container

```console
export RHOKP_KEY="key from RHN"

podman run --rm -p 8080:8080 -p 8443:8443 \
--env "ACCESS_KEY=${RHOKP_KEY}" \
-d registry.redhat.io/offline-knowledge-portal/rhokp-rhel9:latest
```

## Deploy the RHOKP to OpenShift

### Security

The deployment creates a dedicated `rhokp-server` ServiceAccount with:

- **SCC v2 (restricted-v2):** `runAsNonRoot`, `allowPrivilegeEscalation: false`, drops all Linux capabilities, and sets a read-only root filesystem. These settings satisfy the OpenShift `restricted-v2` SCC which is the default for all authenticated service accounts — no custom SCC or RBAC role is required.
- **Seccomp:** `RuntimeDefault` profile applied at the pod level.
- **API token:** `automountServiceAccountToken: false` prevents the Kubernetes API token from being mounted into the pod since the application does not need cluster API access.

### Deploy

1. Create a new namespace

```console
oc new-project rhokp-server
```

2. Deploy RHOKP

```console
export RHOKP_KEY="RHOKP key from RHN"

envsubst < rhokp-deployment.yaml | oc apply -f -
```

3. Verify the deployment rolled out and pods are running under the service account

```console
oc rollout status deployment/rhokp-server -n rhokp-server
oc get pods -n rhokp-server -o custom-columns='NAME:.metadata.name,SA:.spec.serviceAccountName,STATUS:.status.phase'
```

4. Access the route

```console
oc get route rhokp-server -n rhokp-server -o jsonpath='{.spec.host}'
```

### Future: Update deployment to limit where the pod can write within its filesystem

The pods will fail to start with a read-only filesystem error when read only FS is set, the application needs additional writable mount points. Determine and add more `emptyDir` volumes as needed:

```yaml
volumeMounts:
- name: app-cache
  mountPath: /path/to/writable/dir
volumes:
- name: app-cache
  emptyDir:
    sizeLimit: 128Mi
```
