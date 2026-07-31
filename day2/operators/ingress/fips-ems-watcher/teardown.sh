#!/bin/bash
# Remove all FIPS EMS watcher resources.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Deleting deployment and configmap..."
oc delete -f "$SCRIPT_DIR/deployment.yaml" --ignore-not-found
oc delete configmap fips-ems-watcher-script -n fips-ems-watcher --ignore-not-found

echo "==> Deleting RBAC, NetworkPolicy, and namespace..."
oc delete -f "$SCRIPT_DIR/manifests.yaml" --ignore-not-found

echo "==> Teardown complete."
