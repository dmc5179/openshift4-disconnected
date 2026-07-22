#!/usr/bin/env bash
# Apply RHDH Operator configuration for platform template governance.
# Usage: ./apply.sh [NAMESPACE]
set -euo pipefail

NS="${1:-rhdh-operator}"

echo "==> Targeting namespace: ${NS}"

# 1. Create the namespace if it doesn't exist
oc get namespace "${NS}" &>/dev/null || oc create namespace "${NS}"

# 2. Create the secrets ConfigMap (if it doesn't already exist).
#    You must populate rhdh-secrets with your Git provider tokens.
if ! oc get secret rhdh-secrets -n "${NS}" &>/dev/null; then
  echo "==> Creating rhdh-secrets placeholder — edit with your real tokens"
  oc create secret generic rhdh-secrets -n "${NS}" \
    --from-literal=GITHUB_TOKEN="ghp_REPLACE_ME" \
    --from-literal=GITLAB_TOKEN="glpat-REPLACE_ME"
  echo "    WARNING: Replace placeholder tokens in rhdh-secrets before proceeding."
fi

# 3. Apply the app-config ConfigMap
echo "==> Applying app-config-rhdh ConfigMap"
oc apply -f app-config-rhdh.yaml -n "${NS}"

# 4. Create the RBAC policy ConfigMap from the CSV source file
echo "==> Creating rbac-policy ConfigMap from rbac-policy.csv"
oc create configmap rbac-policy \
  --from-file=rbac-policy.csv=rbac-policy.csv \
  -n "${NS}" \
  --dry-run=client -o yaml | oc apply -f - -n "${NS}"

# 5. Apply the Backstage CR patch
echo "==> Applying Backstage CR"
oc apply -f backstage-cr-patch.yaml -n "${NS}"

echo ""
echo "Done. RHDH will reconcile and restart with the new configuration."
echo "Monitor with: oc get pods -n ${NS} -w"
