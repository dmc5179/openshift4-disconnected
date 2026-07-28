# OpenShift Certificate Recovery for Extended Shutdown

Recover non-etcd certificates on an OpenShift 4 cluster that has been powered off for more than 100 days.

## Background

OpenShift internal certificates (kubelet, kube-apiserver serving, signers) expire after the cluster has been shut down beyond the supported window (90 days for OCP 4.18+, 30 days for earlier versions). When certificates expire, the API becomes unreachable and nodes report `NotReady`. This script automates the recovery procedure across two phases.

**Etcd certificates are not handled by this script.** Address etcd separately if needed.

### Reference Articles

| Source | Description |
|--------|-------------|
| [Solution 7134793](https://access.redhat.com/solutions/7134793) | Recovering a cluster powered off 100+ days |
| [Solution 6992388](https://access.redhat.com/solutions/6992388) | Recovery when all node certificates have expired |
| [Regenerating Cluster Certificates](https://access.redhat.com/articles/regenerating_cluster_certificates) | Full certificate regeneration procedure |

## Prerequisites

- `oc` CLI version 4.11 or later (must support `oc adm ocp-certificates`)
- SSH access to all control plane nodes (for Phase 1)
- `cluster-admin` privileges (for Phase 2)
- Root access on control plane nodes (for Phase 1)

## Usage

```
./ocp-cert-recovery.sh {diagnose|phase1|phase2}
```

### Step 1: Diagnose (optional, safe)

Run from any control plane node via SSH to assess the current state before making changes.

```bash
sudo ./ocp-cert-recovery.sh diagnose
```

This checks:
- Kubelet certificate expiry dates
- kube-apiserver health on localhost
- Available recovery kubeconfigs on the node
- Pending CSRs (if the API is reachable)
- etcd container status

No changes are made. Safe to run at any time.

### Step 2: Phase 1 — Bootstrap API Access

Run this **via SSH on each control plane node**, starting with one. This phase recovers enough certificate state to make the Kubernetes API accessible again.

```bash
# SSH to a control plane node
ssh core@<control-plane-node>

# Copy the script to the node (or curl/scp it)
scp ocp-cert-recovery.sh core@<control-plane-node>:~/

# Run Phase 1 as root
sudo ./ocp-cert-recovery.sh phase1
```

What it does:
1. Locates a usable kubeconfig on the node (`lb-int.kubeconfig` or `localhost-recovery` kubeconfig)
2. Backs up `/var/lib/kubelet/pki` to `/tmp/`
3. Stops kubelet and clears expired kubelet certificates
4. Restarts kubelet to trigger new certificate signing requests
5. Approves pending CSRs in a loop

**Repeat Phase 1 on every control plane node.** Once all control plane nodes show `Ready` and the API is reachable from outside the cluster, proceed to Phase 2.

### Step 3: Phase 2 — Full Certificate Regeneration

Run this from any host where `oc` is configured with cluster-admin access and can reach the API.

```bash
export KUBECONFIG=/path/to/kubeconfig
./ocp-cert-recovery.sh phase2
```

What it does (in order):
1. Regenerates leaf certificates (kube-controller-manager, kube-scheduler, kube-apiserver)
2. Regenerates root signer certificates (5 signers in `openshift-kube-apiserver-operator`)
3. Rotates service account signing keys
4. Creates and distributes a new bootstrap kubeconfig to all nodes
5. Restarts all kubelets and reboots all nodes
6. Re-regenerates leaf certificates with the new signers
7. Creates a new admin kubeconfig
8. Regenerates the ingress (router) CA
9. Revokes trust for all old signer certificates
10. Final node reboot

Each destructive step requires interactive confirmation before proceeding.

## Output

| Artifact | Location |
|----------|----------|
| Log file | `/tmp/ocp-cert-recovery-YYYYMMDD-HHMMSS.log` |
| PKI backup | `/tmp/ocp-cert-backup-YYYYMMDD-HHMMSS/` |
| New admin kubeconfig | `/tmp/admin-YYYYMMDDHHMMSS.kubeconfig` |

## Post-Recovery Verification

After Phase 2 completes:

```bash
oc get nodes                     # All nodes should be Ready
oc get co                        # All cluster operators should be Available
oc get csr                       # No stuck Pending CSRs
oc adm wait-for-stable-cluster   # Should complete without errors
```

## Important Notes

- **Do not skip steps.** Once root signers are regenerated (Step 2.5 in Phase 2), all remaining steps must be completed as quickly as possible.
- **Run Phase 1 on all control plane nodes** before starting Phase 2.
- **Etcd is excluded.** If etcd certificates are also expired, recover those separately before or after this procedure.
- **This is a workaround.** Red Hat does not support keeping a cluster powered off beyond the certificate validity window. Recovery is not guaranteed for all configurations.
- **Back up first.** The script backs up kubelet PKI automatically, but consider taking etcd snapshots and node backups before starting.
