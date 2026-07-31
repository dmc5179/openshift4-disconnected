#!/bin/bash
# Deploy the FIPS EMS watcher to the current OpenShift cluster.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Creating namespace, RBAC, and NetworkPolicy..."
oc apply -f "$SCRIPT_DIR/manifests.yaml"

echo "==> Creating ConfigMap from watcher script..."
oc create configmap fips-ems-watcher-script \
  --from-file=watcher.sh="$SCRIPT_DIR/watcher.sh" \
  -n fips-ems-watcher \
  --dry-run=client -o yaml | oc apply -f -

echo "==> Deploying watcher pod..."
oc apply -f "$SCRIPT_DIR/deployment.yaml"

echo "==> Waiting for rollout..."
oc rollout status deployment/fips-ems-watcher -n fips-ems-watcher --timeout=120s

echo "==> Done. Tail logs with:"
echo "    oc logs -f deployment/fips-ems-watcher -n fips-ems-watcher"
