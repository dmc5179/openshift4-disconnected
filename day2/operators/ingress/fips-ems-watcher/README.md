# FIPS EMS Watcher for OpenShift Ingress Router Pods

A lightweight Kubernetes controller that monitors OpenShift ingress router pods and modifies their crypto policies to allow TLS 1.2 without Extended Master Secret (EMS) on FIPS 140-3 enabled clusters.

> **Warning:** This modification relaxes the FIPS 140-3 requirement for EMS on TLS 1.2 connections. This is **not supported by Red Hat**. Use only when you have clients that cannot negotiate TLS 1.3 or TLS 1.2 with EMS, and you accept the reduced security posture.

## Background

OpenShift 4.22 on FIPS-enabled clusters enforces FIPS 140-3, which requires either TLS 1.3 or TLS 1.2 with EMS. Previous OpenShift versions included the `update-crypto-policies` binary inside router pods, which could be used to relax this requirement. That binary is no longer present in 4.22.

This tool automates the equivalent workaround: it watches for router pod starts or restarts, then execs into each pod to modify the OpenSSL configuration files and reload HAProxy so the changes take effect without terminating the pod.

### What it modifies inside each router pod

1. **`/etc/pki/tls/fips_local.cnf`** — appends a `[fips_sect]` block that disables the EMS check:
   ```ini
   [fips_sect]
   tls1-prf-ems-check = 0
   activate = 1
   ```

2. **`/etc/pki/tls/openssl.cnf`** — adds `Options=RHNoEnforceEMSinFIPS` under the `[crypto_policy]` section.

3. **HAProxy reload** — sends a signal (default `USR1`) to the HAProxy process so it re-initializes OpenSSL with the updated configuration. The pod does not restart.

## Prerequisites

- OpenShift 4.22 cluster with FIPS enabled at install time
- `oc` CLI authenticated as a user with `cluster-admin` or sufficient privileges to create namespaces, Roles in `openshift-ingress`, and RoleBindings
- Access to `registry.redhat.io/openshift4/ose-cli:v4.22` (or your mirror registry equivalent)

## Files

```
fips-ems-watcher/
├── manifests.yaml    # Namespace, ServiceAccount, Role, RoleBinding, NetworkPolicy
├── deployment.yaml   # Watcher Deployment
├── watcher.sh        # Poll loop script
├── deploy.sh         # One-command deploy
└── teardown.sh       # Clean removal of all resources
```

## Quick start

### 1. Customize the configuration

Open `deployment.yaml` and review the environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `WATCH_NAMESPACE` | `openshift-ingress` | Namespace where router pods run |
| `LABEL_SELECTOR` | `ingresscontroller.operator.openshift.io/deployment-ingresscontroller=default` | Label selector for router pods. Change the value to your IngressController name if not `default`. |
| `CONTAINER_NAME` | `router` | Container name inside the router pod |
| `POLL_INTERVAL` | `15` | Seconds between polls for unpatched pods |
| `SETTLE_SECONDS` | `5` | Seconds to wait on startup before the first poll |
| `HAPROXY_RELOAD_CMD` | `kill -USR1 $(cat /var/lib/haproxy/run/haproxy.pid)` | Command executed inside the router pod to reload HAProxy. **Replace this with your specific reload command** (see [Configuring the HAProxy reload command](#configuring-the-haproxy-reload-command)). |

### 2. Verify the API server CIDR

The NetworkPolicy in `manifests.yaml` restricts watcher egress to the Kubernetes API server. The default CIDR is `172.30.0.1/32`. Verify your cluster's API server address:

```bash
oc get endpoints kubernetes -n default -o jsonpath='{.subsets[0].addresses[0].ip}'
```

If it differs, update the `cidr` value in the NetworkPolicy egress rule in `manifests.yaml`.

### 3. Deploy

```bash
chmod +x deploy.sh
./deploy.sh
```

Or step by step:

```bash
oc apply -f manifests.yaml
oc create configmap fips-ems-watcher-script \
  --from-file=watcher.sh=watcher.sh \
  -n fips-ems-watcher \
  --dry-run=client -o yaml | oc apply -f -
oc apply -f deployment.yaml
```

### 4. Verify

Check the watcher logs:

```bash
oc logs -f deployment/fips-ems-watcher -n fips-ems-watcher
```

You should see output like:

```
[2026-07-31T14:00:05Z] FIPS EMS Watcher starting
[2026-07-31T14:00:05Z]   Namespace:      openshift-ingress
[2026-07-31T14:00:05Z]   Label selector: ingresscontroller.operator.openshift.io/deployment-ingresscontroller=default
[2026-07-31T14:00:05Z]   Container:      router
[2026-07-31T14:00:05Z]   Poll interval:  15s
[2026-07-31T14:00:10Z] Patching crypto policy in pod router-default-7b9f5d6c4-xk2lm ...
[2026-07-31T14:00:11Z] Successfully patched pod router-default-7b9f5d6c4-xk2lm
```

Confirm the patch was applied inside a router pod:

```bash
oc exec -n openshift-ingress <router-pod-name> -c router -- \
  grep 'tls1-prf-ems-check' /etc/pki/tls/fips_local.cnf

oc exec -n openshift-ingress <router-pod-name> -c router -- \
  grep 'RHNoEnforceEMSinFIPS' /etc/pki/tls/openssl.cnf
```

### 5. Remove

```bash
chmod +x teardown.sh
./teardown.sh
```

This deletes the Deployment, ConfigMap, RBAC resources, NetworkPolicy, and the `fips-ems-watcher` namespace. Router pods are unaffected — their current crypto config remains until they restart, at which point they revert to default FIPS policy (since the watcher is no longer running).

## Configuring the HAProxy reload command

The default reload sends `SIGUSR1` to the HAProxy process, which triggers a graceful re-exec. If your environment uses a different mechanism — for example, a `nohup` re-exec command — set the `HAPROXY_RELOAD_CMD` environment variable in `deployment.yaml`:

```yaml
- name: HAPROXY_RELOAD_CMD
  value: "nohup /usr/sbin/haproxy -f /var/lib/haproxy/conf/haproxy.config -p /var/lib/haproxy/run/haproxy.pid -x /var/lib/haproxy/run/haproxy.sock -sf $(cat /var/lib/haproxy/run/haproxy.pid) &"
```

The command is executed via `sh -c` inside the router pod. It must cause HAProxy to re-initialize (and thus re-read the OpenSSL configuration) without the main container process exiting, which would trigger a pod restart.

After changing the variable, redeploy:

```bash
oc rollout restart deployment/fips-ems-watcher -n fips-ems-watcher
```

## How it works

The watcher runs a simple poll loop:

1. Every `POLL_INTERVAL` seconds, query the Kubernetes API for router pods in the `openshift-ingress` namespace that match the label selector and are in `Running` phase with `Ready` condition `True`.
2. For each Ready pod, check idempotently whether `tls1-prf-ems-check = 0` already exists in `/etc/pki/tls/fips_local.cnf`.
3. If not present, exec into the pod and apply both file modifications, then trigger the HAProxy reload.
4. On the next poll cycle, the idempotency check skips already-patched pods.

Container restarts reset the pod's filesystem to the image defaults, clearing the patches. The watcher detects this on the next poll and re-applies them automatically.

### Timing window

There is a window of up to `POLL_INTERVAL` seconds between a router pod becoming Ready and the crypto policy being relaxed. During this window, the router enforces default FIPS 140-3 policy (TLS 1.2 with EMS required). If this window is a concern, reduce `POLL_INTERVAL` to a lower value such as `5`.

## Least-privilege design

The watcher is locked down across five layers:

### 1. Dedicated namespace

The watcher runs in its own `fips-ems-watcher` namespace, isolated from application workloads and OpenShift infrastructure namespaces.

### 2. Namespace-scoped RBAC

A `Role` (not a `ClusterRole`) is created in the `openshift-ingress` namespace with the minimum required permissions:

| Resource | Verbs | Purpose |
|----------|-------|---------|
| `pods` | `get`, `list`, `watch` | Discover and monitor router pods |
| `pods/exec` | `create` | Execute the crypto policy modification commands inside router pods |

A `RoleBinding` binds the watcher's ServiceAccount (in `fips-ems-watcher` namespace) to this Role. The watcher has **zero permissions** in any other namespace.

### 3. Pod Security Standards

The `fips-ems-watcher` namespace is labeled with `restricted` enforcement:

```yaml
pod-security.kubernetes.io/enforce: restricted
pod-security.kubernetes.io/audit: restricted
pod-security.kubernetes.io/warn: restricted
```

This ensures that only pods meeting the `restricted` profile can run in the namespace — no root, no privilege escalation, no host access, mandatory seccomp.

### 4. Container security context

The watcher container itself runs with:

| Setting | Value | Effect |
|---------|-------|--------|
| `runAsNonRoot` | `true` | Container must run as a non-root UID |
| `allowPrivilegeEscalation` | `false` | No setuid/setgid, no gaining capabilities |
| `readOnlyRootFilesystem` | `true` | Container cannot write to its own filesystem (script is mounted read-only from a ConfigMap, temp space from an emptyDir) |
| `capabilities.drop` | `ALL` | All Linux capabilities removed |
| `seccompProfile.type` | `RuntimeDefault` | Default seccomp profile applied (blocks dangerous syscalls) |

### 5. NetworkPolicy

An egress NetworkPolicy restricts the watcher pod's network access:

- **Egress allowed to:** Kubernetes API server (`172.30.0.1:443`) and DNS (UDP/TCP port 53)
- **Egress denied to:** everything else — the internet, other namespaces, other cluster services
- **Ingress denied:** all inbound connections blocked

This prevents the watcher pod from being used as a pivot point for lateral movement if compromised.

### What cannot be further restricted

The `pods/exec` permission is inherently powerful — it allows arbitrary command execution inside any pod in the `openshift-ingress` namespace. Kubernetes RBAC does not support restricting `pods/exec` to specific pod names by label selector (only by static `resourceNames`, which don't work for pods with generated suffixes). The namespace scoping, NetworkPolicy, and pod security constraints are the practical mitigation.

## Updating the watcher script

To modify `watcher.sh` after deployment:

```bash
# Edit watcher.sh locally, then:
oc create configmap fips-ems-watcher-script \
  --from-file=watcher.sh=watcher.sh \
  -n fips-ems-watcher \
  --dry-run=client -o yaml | oc apply -f -

# Restart to pick up the new script:
oc rollout restart deployment/fips-ems-watcher -n fips-ems-watcher
```

## Multiple IngressControllers

If your cluster has multiple IngressControllers, deploy one watcher per controller by duplicating the Deployment with a different `LABEL_SELECTOR` value. The RBAC resources are shared — the Role already grants access to all pods in `openshift-ingress`.

For example, for an IngressController named `custom`:

```yaml
- name: LABEL_SELECTOR
  value: "ingresscontroller.operator.openshift.io/deployment-ingresscontroller=custom"
```

## Troubleshooting

**Watcher logs show `ERROR: failed to modify fips_local.cnf`**
The router container may have a read-only filesystem at `/etc/pki/tls/`. Check:
```bash
oc exec -n openshift-ingress <router-pod> -c router -- touch /etc/pki/tls/.writetest && echo writable || echo read-only
```

**Watcher pod stuck in `Pending`**
The `ose-cli` image may not be pullable. Check events:
```bash
oc describe pod -n fips-ems-watcher -l app.kubernetes.io/name=fips-ems-watcher
```
If using a mirror registry, update the image reference in `deployment.yaml`.

**HAProxy reload fails**
Verify the correct reload command by execing into a router pod manually:
```bash
oc exec -n openshift-ingress <router-pod> -c router -- ps aux | grep haproxy
oc exec -n openshift-ingress <router-pod> -c router -- cat /var/lib/haproxy/run/haproxy.pid
```
Update `HAPROXY_RELOAD_CMD` in `deployment.yaml` with the correct command for your environment.

**NetworkPolicy blocks API access**
If your cluster's API server is not at `172.30.0.1`, the watcher will fail with connection errors. Check the correct address and update the NetworkPolicy CIDR:
```bash
oc get endpoints kubernetes -n default
```
