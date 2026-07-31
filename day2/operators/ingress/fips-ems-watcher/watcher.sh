#!/bin/bash
# fips-ems-watcher.sh
# Polls for Ready openshift-ingress router pods and modifies their crypto
# policies to allow TLS 1.2 without EMS (FIPS 140-3 relaxation).
# Idempotent: safe to run repeatedly; skips pods already patched.

set -euo pipefail

NAMESPACE="${WATCH_NAMESPACE:-openshift-ingress}"
LABEL_SELECTOR="${LABEL_SELECTOR:-ingresscontroller.operator.openshift.io/deployment-ingresscontroller=default}"
CONTAINER="${CONTAINER_NAME:-router}"
POLL_INTERVAL="${POLL_INTERVAL:-15}"
SETTLE_SECONDS="${SETTLE_SECONDS:-5}"

log() { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] $*"; }

is_patched() {
  local pod="$1"
  oc exec "$pod" -c "$CONTAINER" -n "$NAMESPACE" -- \
    grep -q 'tls1-prf-ems-check = 0' /etc/pki/tls/fips_local.cnf 2>/dev/null
}

patch_pod() {
  local pod="$1"

  if is_patched "$pod"; then
    return 0
  fi

  log "Patching crypto policy in pod $pod ..."

  # 1. Append FIPS section disabling EMS check
  if ! oc exec "$pod" -c "$CONTAINER" -n "$NAMESPACE" -- \
    sh -c 'printf "[fips_sect]\ntls1-prf-ems-check = 0\nactivate = 1\n" >> /etc/pki/tls/fips_local.cnf'; then
    log "ERROR: failed to modify fips_local.cnf in $pod"
    return 1
  fi

  # 2. Add RHNoEnforceEMSinFIPS option to openssl.cnf
  if ! oc exec "$pod" -c "$CONTAINER" -n "$NAMESPACE" -- \
    sed -i '/\[crypto_policy\]/a Options=RHNoEnforceEMSinFIPS' /etc/pki/tls/openssl.cnf; then
    log "ERROR: failed to modify openssl.cnf in $pod"
    return 1
  fi

  # 3. Reload haproxy so it picks up the new OpenSSL config.
  #    IMPORTANT: Replace this with your specific nohup reload command.
  #    The command below sends USR1 to haproxy for a graceful re-exec.
  #    If your environment uses a different reload method, update
  #    the HAPROXY_RELOAD_CMD environment variable in the Deployment.
  if ! oc exec "$pod" -c "$CONTAINER" -n "$NAMESPACE" -- \
    sh -c "${HAPROXY_RELOAD_CMD:-kill -USR1 \$(cat /var/lib/haproxy/run/haproxy.pid)}"; then
    log "ERROR: failed to reload haproxy in $pod"
    return 1
  fi

  log "Successfully patched pod $pod"
}

poll_and_patch() {
  local pods
  pods=$(oc get pods -n "$NAMESPACE" -l "$LABEL_SELECTOR" \
    --field-selector=status.phase=Running \
    -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' 2>/dev/null || true)

  for pod in $pods; do
    [[ -z "$pod" ]] && continue

    # Only patch pods whose Ready condition is True
    local ready
    ready=$(oc get pod "$pod" -n "$NAMESPACE" \
      -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || echo "")
    if [[ "$ready" != "True" ]]; then
      continue
    fi

    patch_pod "$pod" || log "WARNING: patch attempt failed for $pod, will retry next cycle"
  done
}

main() {
  log "FIPS EMS Watcher starting"
  log "  Namespace:      $NAMESPACE"
  log "  Label selector: $LABEL_SELECTOR"
  log "  Container:      $CONTAINER"
  log "  Poll interval:  ${POLL_INTERVAL}s"

  # Initial settle time for the watcher pod itself
  sleep "$SETTLE_SECONDS"

  while true; do
    poll_and_patch
    sleep "$POLL_INTERVAL"
  done
}

main "$@"
