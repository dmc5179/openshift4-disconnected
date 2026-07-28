#!/bin/bash
#
# ocp-cert-recovery.sh — Recover non-etcd certificates for an OpenShift 4 cluster
# that has been powered off for 100+ days.
#
# Based on:
#   - https://access.redhat.com/solutions/7134793
#   - https://access.redhat.com/solutions/6992388
#   - https://access.redhat.com/articles/regenerating_cluster_certificates
#
# WARNING: This script is a WORKAROUND. Red Hat does not support keeping an
# OpenShift cluster powered off for more than 90 days (4.18+) or 30 days
# (pre-4.18). Recovery is not guaranteed. Etcd certificates are NOT handled
# by this script — address those separately if needed.
#
# Usage:
#   Phase 1 (run via SSH on a control plane node):
#     sudo ./ocp-cert-recovery.sh phase1
#
#   Phase 2 (run once API is accessible, from any host with oc):
#     ./ocp-cert-recovery.sh phase2
#
#   Diagnostics only (safe to run anytime):
#     ./ocp-cert-recovery.sh diagnose
#
set -euo pipefail

LOGFILE="/tmp/ocp-cert-recovery-$(date +%Y%m%d-%H%M%S).log"
BACKUP_DIR="/tmp/ocp-cert-backup-$(date +%Y%m%d-%H%M%S)"
CSR_APPROVE_ROUNDS=10
CSR_APPROVE_WAIT=30
STABILIZE_TIMEOUT=2700  # 45 minutes

log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $*"
    echo "$msg" | tee -a "$LOGFILE"
}

warn() {
    log "WARNING: $*"
}

err() {
    log "ERROR: $*"
    return 1
}

confirm() {
    local prompt="$1"
    echo ""
    read -rp "$prompt [y/N]: " answer
    [[ "$answer" =~ ^[Yy]$ ]] || { log "Aborted by user."; exit 1; }
}

separator() {
    log "================================================================"
}

# ---------------------------------------------------------------------------
# Diagnostics — safe to run anytime
# ---------------------------------------------------------------------------
diagnose() {
    separator
    log "PHASE: Diagnostics — Checking certificate and cluster state"
    separator

    log ""
    log "--- Checking if running on a control plane node ---"
    if [[ -d /etc/kubernetes/static-pod-resources ]]; then
        log "Static pod resources directory exists — this appears to be a control plane node."
    else
        warn "Not running on a control plane node (no /etc/kubernetes/static-pod-resources)."
    fi

    log ""
    log "--- Checking kubelet certificate expiry ---"
    for cert in /var/lib/kubelet/pki/kubelet-client-current.pem \
                /var/lib/kubelet/pki/kubelet-server-current.pem; do
        if [[ -f "$cert" ]]; then
            expiry=$(openssl x509 -in "$cert" -noout -enddate 2>/dev/null || echo "PARSE_FAILED")
            log "  $cert: $expiry"
        else
            warn "  $cert: NOT FOUND"
        fi
    done

    log ""
    log "--- Checking kube-apiserver serving certificate expiry ---"
    local api_cert_dir="/etc/kubernetes/static-pod-resources/kube-apiserver-certs"
    if [[ -d "$api_cert_dir" ]]; then
        find "$api_cert_dir" -name '*.crt' -o -name '*.pem' 2>/dev/null | head -20 | while read -r cert; do
            if openssl x509 -in "$cert" -noout 2>/dev/null; then
                expiry=$(openssl x509 -in "$cert" -noout -enddate 2>/dev/null)
                subject=$(openssl x509 -in "$cert" -noout -subject 2>/dev/null)
                log "  $cert"
                log "    Subject: $subject"
                log "    Expires: $expiry"
            fi
        done
    else
        warn "  kube-apiserver-certs directory not found."
    fi

    log ""
    log "--- Checking if kube-apiserver is responding on localhost ---"
    local healthz_status
    healthz_status=$(curl -sk https://localhost:6443/healthz 2>/dev/null || echo "UNREACHABLE")
    log "  https://localhost:6443/healthz -> $healthz_status"

    log ""
    log "--- Checking available kubeconfigs on this node ---"
    local kubeconfig_dir="/etc/kubernetes/static-pod-resources/kube-apiserver-certs/secrets/node-kubeconfigs"
    if [[ -d "$kubeconfig_dir" ]]; then
        ls -la "$kubeconfig_dir"/ 2>/dev/null | tee -a "$LOGFILE"
    else
        warn "  Node kubeconfigs directory not found."
    fi

    log ""
    log "--- Attempting oc whoami with lb-int.kubeconfig ---"
    local lb_int_kc="$kubeconfig_dir/lb-int.kubeconfig"
    if [[ -f "$lb_int_kc" ]]; then
        local whoami
        whoami=$(KUBECONFIG="$lb_int_kc" oc whoami 2>&1 || true)
        log "  oc whoami -> $whoami"
    else
        warn "  lb-int.kubeconfig not found."
    fi

    log ""
    log "--- Attempting oc whoami with localhost-recovery.kubeconfig ---"
    local recovery_kc
    recovery_kc=$(find /etc/kubernetes/static-pod-resources -name 'localhost-recovery*kubeconfig' 2>/dev/null | head -1)
    if [[ -n "$recovery_kc" ]]; then
        local whoami
        whoami=$(KUBECONFIG="$recovery_kc" oc whoami 2>&1 || true)
        log "  $recovery_kc"
        log "  oc whoami -> $whoami"
    else
        warn "  localhost-recovery kubeconfig not found."
    fi

    log ""
    log "--- Checking etcd health (for reference, not modified by this script) ---"
    if command -v crictl &>/dev/null; then
        local etcd_container
        etcd_container=$(crictl ps --name etcd -q 2>/dev/null | head -1)
        if [[ -n "$etcd_container" ]]; then
            log "  etcd container is running: $etcd_container"
        else
            warn "  No running etcd container found."
        fi
    fi

    log ""
    log "--- Checking pending CSRs (if API is accessible) ---"
    for kc in "$lb_int_kc" "$recovery_kc"; do
        if [[ -n "${kc:-}" && -f "${kc:-}" ]]; then
            local csrs
            csrs=$(KUBECONFIG="$kc" oc get csr --no-headers 2>/dev/null || echo "API_UNREACHABLE")
            if [[ "$csrs" != "API_UNREACHABLE" ]]; then
                local pending
                pending=$(echo "$csrs" | grep -c "Pending" || true)
                local approved_only
                approved_only=$(echo "$csrs" | grep -c "Approved[^,]" || true)
                local total
                total=$(echo "$csrs" | wc -l)
                log "  Using $kc:"
                log "    Total CSRs: $total"
                log "    Pending: $pending"
                log "    Approved but NOT Issued: $approved_only"
                break
            fi
        fi
    done

    separator
    log "Diagnostics complete. Log saved to: $LOGFILE"
    separator
}

# ---------------------------------------------------------------------------
# Phase 1: Bootstrap API Access (run on a control plane node via SSH)
# ---------------------------------------------------------------------------
phase1() {
    separator
    log "PHASE 1: Bootstrap API Access from Control Plane Node"
    log "This phase must be run as root on a control plane node via SSH."
    separator

    # Verify we are root
    if [[ $EUID -ne 0 ]]; then
        err "Phase 1 must be run as root. Use: sudo $0 phase1"
    fi

    # Verify this is a control plane node
    if [[ ! -d /etc/kubernetes/static-pod-resources ]]; then
        err "This does not appear to be a control plane node."
    fi

    log ""
    log "Step 1.1: Locating usable kubeconfig on this node..."
    separator

    local RECOVERY_KUBECONFIG=""

    # Try lb-int.kubeconfig first (internal load balancer)
    local lb_int="/etc/kubernetes/static-pod-resources/kube-apiserver-certs/secrets/node-kubeconfigs/lb-int.kubeconfig"
    if [[ -f "$lb_int" ]]; then
        log "  Found: $lb_int"
        RECOVERY_KUBECONFIG="$lb_int"
    fi

    # Try localhost-recovery kubeconfig
    local recovery_kc
    recovery_kc=$(find /etc/kubernetes/static-pod-resources -name 'localhost-recovery*kubeconfig' 2>/dev/null | head -1)
    if [[ -n "$recovery_kc" ]]; then
        log "  Found: $recovery_kc"
        # Prefer localhost-recovery if lb-int doesn't work
        if [[ -z "$RECOVERY_KUBECONFIG" ]]; then
            RECOVERY_KUBECONFIG="$recovery_kc"
        fi
    fi

    if [[ -z "$RECOVERY_KUBECONFIG" ]]; then
        err "No usable kubeconfig found on this node. Cannot proceed."
    fi

    export KUBECONFIG="$RECOVERY_KUBECONFIG"
    log "  Using: $KUBECONFIG"

    log ""
    log "Step 1.2: Backing up existing kubelet PKI..."
    separator

    mkdir -p "$BACKUP_DIR"
    if [[ -d /var/lib/kubelet/pki ]]; then
        cp -a /var/lib/kubelet/pki "$BACKUP_DIR/kubelet-pki-backup"
        log "  Backed up /var/lib/kubelet/pki to $BACKUP_DIR/kubelet-pki-backup"
    else
        warn "  /var/lib/kubelet/pki does not exist."
    fi

    log ""
    log "Step 1.3: Checking if kube-apiserver is responding on localhost..."
    separator

    local api_up=false
    local healthz
    healthz=$(curl -sk https://localhost:6443/healthz 2>/dev/null || echo "UNREACHABLE")
    if [[ "$healthz" == "ok" ]]; then
        log "  kube-apiserver is responding: $healthz"
        api_up=true
    else
        log "  kube-apiserver response: $healthz"
        log "  API may not be fully functional yet. Will attempt recovery."
    fi

    log ""
    log "Step 1.4: Stopping kubelet and clearing expired kubelet certificates..."
    separator

    confirm "This will stop kubelet and remove expired certs from /var/lib/kubelet/pki. Continue?"

    systemctl stop kubelet
    log "  kubelet stopped."

    if [[ -d /var/lib/kubelet/pki ]]; then
        rm -rf /var/lib/kubelet/pki/*
        log "  Cleared /var/lib/kubelet/pki/"
    fi

    log ""
    log "Step 1.5: Restarting kubelet to trigger certificate re-request..."
    separator

    systemctl start kubelet
    log "  kubelet started. Waiting 30 seconds for CSR generation..."
    sleep 30

    log ""
    log "Step 1.6: Attempting to approve pending CSRs..."
    separator

    # Try with the recovery kubeconfig — the API may or may not be accessible
    local csr_approved=false
    for round in $(seq 1 $CSR_APPROVE_ROUNDS); do
        log "  CSR approval round $round/$CSR_APPROVE_ROUNDS..."

        local pending_csrs
        pending_csrs=$(oc get csr --no-headers 2>/dev/null | grep -i "pending" | awk '{print $1}' || true)

        if [[ -n "$pending_csrs" ]]; then
            echo "$pending_csrs" | while read -r csr; do
                oc adm certificate approve "$csr" 2>/dev/null && \
                    log "    Approved: $csr" || \
                    warn "    Failed to approve: $csr"
            done
            csr_approved=true
        else
            local all_csrs
            all_csrs=$(oc get csr --no-headers 2>/dev/null || echo "API_UNREACHABLE")
            if [[ "$all_csrs" == "API_UNREACHABLE" ]]; then
                warn "    API not reachable yet. Waiting ${CSR_APPROVE_WAIT}s..."
            else
                log "    No pending CSRs found."
                if [[ "$csr_approved" == "true" ]]; then
                    log "    All CSRs have been processed."
                    break
                fi
            fi
        fi

        if [[ $round -lt $CSR_APPROVE_ROUNDS ]]; then
            sleep "$CSR_APPROVE_WAIT"
        fi
    done

    log ""
    log "Step 1.7: Checking node status..."
    separator

    local nodes
    nodes=$(oc get nodes --no-headers 2>/dev/null || echo "API_UNREACHABLE")
    if [[ "$nodes" == "API_UNREACHABLE" ]]; then
        warn "Cannot reach API to check node status."
        log ""
        log "If the API is still unreachable on this node, try switching kubeconfigs:"
        log "  export KUBECONFIG=$lb_int"
        log "  oc get nodes"
        log ""
        log "Or try the localhost-recovery kubeconfig:"
        log "  export KUBECONFIG=$recovery_kc"
        log "  oc get nodes"
    else
        log "$nodes"
    fi

    separator
    log "Phase 1 complete."
    log ""
    log "NEXT STEPS:"
    log "  1. Repeat Phase 1 on ALL other control plane nodes (SSH in, run: sudo $0 phase1)"
    log "  2. Once all control plane nodes show Ready, approve worker CSRs:"
    log "     export KUBECONFIG=$RECOVERY_KUBECONFIG"
    log "     oc get csr -o name | xargs oc adm certificate approve"
    log "  3. Wait for all nodes to become Ready: oc get nodes"
    log "  4. Run Phase 2 for full certificate regeneration: $0 phase2"
    log ""
    log "Log saved to: $LOGFILE"
    log "Backup saved to: $BACKUP_DIR"
    separator
}

# ---------------------------------------------------------------------------
# Phase 2: Full Certificate Regeneration (run once API is accessible)
# ---------------------------------------------------------------------------
phase2() {
    separator
    log "PHASE 2: Full Certificate Regeneration"
    log "This phase requires a working 'oc' CLI with cluster-admin access."
    log "Etcd certificates are NOT touched by this script."
    separator

    # Verify oc is available and working
    local whoami
    whoami=$(oc whoami 2>/dev/null || echo "FAILED")
    if [[ "$whoami" == "FAILED" ]]; then
        err "Cannot run 'oc whoami'. Ensure KUBECONFIG is set and API is accessible."
    fi
    log "  Authenticated as: $whoami"

    # Verify cluster-admin
    local can_admin
    can_admin=$(oc auth can-i '*' '*' 2>/dev/null || echo "no")
    if [[ "$can_admin" != "yes" ]]; then
        err "Current user does not have cluster-admin privileges."
    fi
    log "  Confirmed cluster-admin access."

    # Check oc version supports ocp-certificates subcommand
    if ! oc adm ocp-certificates --help &>/dev/null 2>&1; then
        err "'oc adm ocp-certificates' not available. Ensure oc CLI is version 4.11+."
    fi

    log ""
    log "Pre-flight: Recording start timestamp..."
    local START_DATE
    START_DATE=$(date +"%Y-%m-%dT%H:%M:%S%:z")
    log "  Start date: $START_DATE (needed for trust revocation in final steps)"

    log ""
    log "Pre-flight: Checking cluster stability..."
    oc adm wait-for-stable-cluster --minimum-stable-period=5s 2>&1 | tee -a "$LOGFILE" || {
        warn "Cluster may not be fully stable. This is expected after extended shutdown."
        confirm "Cluster is not fully stable. Continue anyway?"
    }

    # ===== STEP 1: Regenerate Leaf Certificates =====
    separator
    log "Step 2.1: Regenerating leaf certificates (openshift-config-managed)..."
    separator

    confirm "Regenerate kube-controller-manager and kube-scheduler client certificates?"

    oc adm ocp-certificates regenerate-leaf \
        -n openshift-config-managed secrets \
        kube-controller-manager-client-cert-key \
        kube-scheduler-client-cert-key 2>&1 | tee -a "$LOGFILE"

    log "  Done."

    # ===== STEP 2: Regenerate Leaf Certificates (kube-apiserver-operator) =====
    separator
    log "Step 2.2: Regenerating leaf certificates (kube-apiserver-operator)..."
    separator

    oc adm ocp-certificates regenerate-leaf \
        -n openshift-kube-apiserver-operator secrets \
        node-system-admin-client 2>&1 | tee -a "$LOGFILE"

    log "  Done."

    # ===== STEP 3: Regenerate Leaf Certificates (kube-apiserver) =====
    separator
    log "Step 2.3: Regenerating leaf certificates (kube-apiserver)..."
    separator

    oc adm ocp-certificates regenerate-leaf \
        -n openshift-kube-apiserver secrets \
        check-endpoints-client-cert-key \
        control-plane-node-admin-client-cert-key \
        external-loadbalancer-serving-certkey \
        internal-loadbalancer-serving-certkey \
        kubelet-client \
        localhost-recovery-serving-certkey \
        localhost-serving-cert-certkey \
        service-network-serving-certkey 2>&1 | tee -a "$LOGFILE"

    log "  Done."

    # ===== STEP 4: Wait for stabilization =====
    separator
    log "Step 2.4: Waiting for cluster stabilization (this can take 30 minutes)..."
    separator

    oc adm wait-for-stable-cluster --timeout="${STABILIZE_TIMEOUT}s" 2>&1 | tee -a "$LOGFILE" || {
        warn "Cluster did not fully stabilize within timeout."
        confirm "Continue despite incomplete stabilization?"
    }

    # ===== STEP 5: Regenerate Root Signers =====
    separator
    log "Step 2.5: Regenerating ROOT SIGNER certificates..."
    log ""
    log "  *** CRITICAL: Once this step completes, you MUST finish ALL remaining ***"
    log "  *** steps (through node reboot) as quickly as possible.              ***"
    separator

    confirm "Regenerate all root signer certificates? THIS IS THE POINT OF NO RETURN."

    oc adm ocp-certificates regenerate-top-level \
        -n openshift-kube-apiserver-operator secrets \
        kube-apiserver-to-kubelet-signer \
        kube-control-plane-signer \
        loadbalancer-serving-signer \
        localhost-serving-signer \
        service-network-serving-signer 2>&1 | tee -a "$LOGFILE"

    log "  Root signers regenerated."

    # ===== STEP 6: Rotate Service Account Signing Keys =====
    separator
    log "Step 2.6: Rotating service account signing keys..."
    separator

    oc -n openshift-kube-controller-manager-operator \
        delete secrets/next-service-account-private-key 2>&1 | tee -a "$LOGFILE" || \
        warn "Secret next-service-account-private-key may not exist (ok if already rotated)."

    oc -n openshift-kube-apiserver-operator \
        delete secrets/next-bound-service-account-signing-key 2>&1 | tee -a "$LOGFILE" || \
        warn "Secret next-bound-service-account-signing-key may not exist (ok if already rotated)."

    log "  Service account keys rotated."

    # ===== STEP 7: Wait for stabilization =====
    separator
    log "Step 2.7: Waiting for cluster stabilization (this can take 30-45 minutes)..."
    separator

    oc adm wait-for-stable-cluster --timeout="${STABILIZE_TIMEOUT}s" 2>&1 | tee -a "$LOGFILE" || {
        warn "Cluster did not fully stabilize within timeout."
        confirm "Continue despite incomplete stabilization?"
    }

    # ===== STEP 8: Regenerate Leaf Certs Again (after new signers) =====
    separator
    log "Step 2.8: Re-regenerating leaf certificates with new signers..."
    separator

    oc adm ocp-certificates regenerate-leaf \
        -n openshift-config-managed secrets \
        kube-controller-manager-client-cert-key \
        kube-scheduler-client-cert-key 2>&1 | tee -a "$LOGFILE"

    log "  Done."

    # ===== STEP 9: Refresh local kubeconfig CA bundle =====
    separator
    log "Step 2.9: Refreshing local kubeconfig CA bundle..."
    separator

    oc config refresh-ca-bundle 2>&1 | tee -a "$LOGFILE" || \
        warn "refresh-ca-bundle not available in this oc version. You may need to manually update."

    log "  Done."

    # ===== STEP 10: Create and distribute new bootstrap kubeconfig =====
    separator
    log "Step 2.10: Creating new kubelet bootstrap kubeconfig..."
    separator

    local BOOTSTRAP_KC="/tmp/bootstrap-$(date +%Y%m%d%H%M%S).kubeconfig"
    oc config new-kubelet-bootstrap-kubeconfig > "$BOOTSTRAP_KC" 2>&1
    log "  Created: $BOOTSTRAP_KC"

    # Verify it works
    local bootstrap_whoami
    local api_url
    api_url=$(oc get infrastructure/cluster -ojsonpath='{ .status.apiServerURL }' 2>/dev/null)
    bootstrap_whoami=$(oc whoami --kubeconfig="$BOOTSTRAP_KC" --server="$api_url" 2>/dev/null || echo "FAILED")
    if [[ "$bootstrap_whoami" == *"node-bootstrapper"* ]]; then
        log "  Verified: $bootstrap_whoami"
    else
        warn "  Bootstrap kubeconfig verification returned: $bootstrap_whoami"
        confirm "Bootstrap kubeconfig may not be working. Continue?"
    fi

    separator
    log "Step 2.11: Copying bootstrap kubeconfig to ALL nodes..."
    separator

    oc adm copy-to-node nodes --all \
        --copy="$BOOTSTRAP_KC=/etc/kubernetes/kubeconfig" 2>&1 | tee -a "$LOGFILE"

    log "  Done."

    # ===== STEP 11: Restart kubelets =====
    separator
    log "Step 2.12: Restarting all kubelets..."
    separator

    confirm "Restart kubelet on ALL nodes? This will temporarily disrupt workloads."

    oc adm restart-kubelet nodes --all \
        --directive=RemoveKubeletKubeconfig 2>&1 | tee -a "$LOGFILE"

    log "  Kubelets restarting."

    # ===== STEP 12: Reboot all nodes =====
    separator
    log "Step 2.13: Rebooting ALL nodes..."
    separator

    confirm "Reboot ALL cluster nodes (masters and workers)?"

    oc adm reboot-machine-config-pool mcp/worker mcp/master 2>&1 | tee -a "$LOGFILE"

    log "  Reboot initiated. Waiting for nodes to come back..."

    oc adm wait-for-node-reboot nodes --all --timeout="${STABILIZE_TIMEOUT}s" 2>&1 | tee -a "$LOGFILE" || {
        warn "Not all nodes rebooted within timeout. Check manually: oc get nodes"
    }

    # ===== STEP 13: Post-reboot leaf cert regeneration =====
    separator
    log "Step 2.14: Post-reboot: Regenerating leaf certificates again..."
    separator

    oc adm ocp-certificates regenerate-leaf \
        -n openshift-kube-apiserver-operator secrets \
        node-system-admin-client 2>&1 | tee -a "$LOGFILE"

    oc adm ocp-certificates regenerate-leaf \
        -n openshift-kube-apiserver secrets \
        check-endpoints-client-cert-key \
        control-plane-node-admin-client-cert-key \
        external-loadbalancer-serving-certkey \
        internal-loadbalancer-serving-certkey \
        kubelet-client \
        localhost-recovery-serving-certkey \
        localhost-serving-cert-certkey \
        service-network-serving-certkey 2>&1 | tee -a "$LOGFILE"

    log "  Done."

    # ===== STEP 14: Wait for stabilization =====
    separator
    log "Step 2.15: Waiting for cluster stabilization..."
    separator

    oc adm wait-for-stable-cluster --timeout="${STABILIZE_TIMEOUT}s" 2>&1 | tee -a "$LOGFILE" || {
        warn "Cluster did not fully stabilize within timeout."
    }

    # ===== STEP 15: Create new admin kubeconfig =====
    separator
    log "Step 2.16: Creating new admin kubeconfig..."
    separator

    local ADMIN_KC="/tmp/admin-$(date +%Y%m%d%H%M%S).kubeconfig"
    oc config new-admin-kubeconfig > "$ADMIN_KC" 2>&1
    log "  Created: $ADMIN_KC"

    local admin_whoami
    admin_whoami=$(oc --kubeconfig="$ADMIN_KC" whoami 2>/dev/null || echo "FAILED")
    log "  Verified: $admin_whoami"

    if [[ "$admin_whoami" == "system:admin" ]]; then
        log "  New admin kubeconfig is working."
        log "  To use it: export KUBECONFIG=$ADMIN_KC"
    else
        warn "  New admin kubeconfig did not verify as system:admin."
    fi

    # ===== STEP 16: Regenerate Ingress CA =====
    separator
    log "Step 2.17: Regenerating ingress (router) CA..."
    separator

    confirm "Delete and regenerate the ingress router-ca certificate?"

    oc -n openshift-ingress-operator delete secrets/router-ca 2>&1 | tee -a "$LOGFILE" || \
        warn "router-ca secret not found (may already be regenerated)."

    log "  Restarting ingress operator to regenerate router-ca..."
    oc -n openshift-ingress-operator delete pods -l name=ingress-operator 2>&1 | tee -a "$LOGFILE"

    log "  Waiting 60 seconds for ingress operator to recreate router-ca..."
    sleep 60

    local router_ca_check
    router_ca_check=$(oc -n openshift-ingress-operator get secrets/router-ca --no-headers 2>/dev/null || echo "NOT_FOUND")
    if [[ "$router_ca_check" != "NOT_FOUND" ]]; then
        log "  router-ca secret has been recreated."
    else
        warn "  router-ca secret not yet recreated. Check: oc -n openshift-ingress-operator get secrets/router-ca"
    fi

    # ===== STEP 17: Revoke trust for old signers =====
    separator
    log "Step 2.18: Revoking trust for old signer certificates..."
    log "  Removing trust for signers created before: $START_DATE"
    separator

    confirm "Revoke old signer trust? This removes trust for all signers issued before this recovery."

    oc adm ocp-certificates remove-old-trust \
        -n openshift-kube-apiserver-operator configmaps \
        kube-apiserver-to-kubelet-client-ca \
        kube-control-plane-signer-ca \
        loadbalancer-serving-ca \
        localhost-serving-ca \
        service-network-serving-ca \
        --created-before="$START_DATE" 2>&1 | tee -a "$LOGFILE"

    log "  Old trust revoked."

    # ===== STEP 18: Final stabilization =====
    separator
    log "Step 2.19: Final cluster stabilization..."
    separator

    oc adm wait-for-stable-cluster --timeout="${STABILIZE_TIMEOUT}s" 2>&1 | tee -a "$LOGFILE" || {
        warn "Cluster did not fully stabilize."
    }

    # ===== STEP 19: Final reboot =====
    separator
    log "Step 2.20: Final node reboot to pick up all certificate changes..."
    separator

    confirm "Reboot ALL nodes one final time?"

    oc adm reboot-machine-config-pool mcp/worker mcp/master 2>&1 | tee -a "$LOGFILE"

    oc adm wait-for-node-reboot nodes --all --timeout="${STABILIZE_TIMEOUT}s" 2>&1 | tee -a "$LOGFILE" || {
        warn "Not all nodes rebooted within timeout."
    }

    # ===== DONE =====
    separator
    log "PHASE 2 COMPLETE — Certificate Recovery Finished"
    separator
    log ""
    log "Summary:"
    log "  - Leaf certificates: Regenerated"
    log "  - Root signers: Regenerated"
    log "  - Service account signing keys: Rotated"
    log "  - Bootstrap kubeconfig: Distributed to all nodes"
    log "  - Ingress CA: Regenerated"
    log "  - Old signer trust: Revoked (before $START_DATE)"
    log "  - Etcd certificates: NOT TOUCHED (handle separately if needed)"
    log ""
    log "  New admin kubeconfig: $ADMIN_KC"
    log "  Log file: $LOGFILE"
    log ""
    log "Post-recovery checks:"
    log "  oc get nodes                    # All nodes should be Ready"
    log "  oc get co                       # All cluster operators should be Available"
    log "  oc get csr                      # No stuck Pending CSRs"
    log "  oc adm wait-for-stable-cluster  # Should complete cleanly"
    separator
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
usage() {
    echo "Usage: $0 {diagnose|phase1|phase2}"
    echo ""
    echo "  diagnose  — Check certificate state and cluster health (safe, read-only)"
    echo "  phase1    — Bootstrap API access from a control plane node (run as root via SSH)"
    echo "  phase2    — Full certificate regeneration (run once API is accessible)"
    echo ""
    echo "References:"
    echo "  https://access.redhat.com/solutions/7134793"
    echo "  https://access.redhat.com/solutions/6992388"
    echo "  https://access.redhat.com/articles/regenerating_cluster_certificates"
    exit 1
}

case "${1:-}" in
    diagnose)
        diagnose
        ;;
    phase1)
        diagnose
        echo ""
        confirm "Diagnostics complete. Proceed with Phase 1 (bootstrap API access)?"
        phase1
        ;;
    phase2)
        phase2
        ;;
    *)
        usage
        ;;
esac
