#!/usr/bin/env bash
# =====================================================================
# RHDH RBAC Setup — oc CLI commands for template governance
# =====================================================================
# This script configures RBAC for platform template governance using
# the RHDH REST API via oc port-forward.
#
# Prerequisites:
#   - oc CLI logged into the cluster
#   - RHDH instance running with permission.enabled: true
#   - You are an RBAC admin (listed in permission.rbac.admin.users)
#
# Usage: ./setup-rbac.sh [NAMESPACE]
# =====================================================================
set -euo pipefail

NS="${1:-rhdh-operator}"
RHDH_POD=""
RHDH_URL=""
LOCAL_PORT=17007

echo "=============================================="
echo " RHDH Platform Template RBAC Setup"
echo "=============================================="
echo ""

# ── Step 1: Find the RHDH pod ──
echo "==> Finding RHDH pod in namespace: ${NS}"
RHDH_POD=$(oc get pods -n "${NS}" -l app.kubernetes.io/name=backstage -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)

if [[ -z "${RHDH_POD}" ]]; then
  RHDH_POD=$(oc get pods -n "${NS}" -l app.kubernetes.io/component=backstage -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)
fi

if [[ -z "${RHDH_POD}" ]]; then
  echo "ERROR: Could not find RHDH pod. Check namespace and labels."
  echo "  Try: oc get pods -n ${NS}"
  exit 1
fi
echo "    Found pod: ${RHDH_POD}"

# ── Step 2: Port-forward to the RHDH backend ──
echo "==> Setting up port-forward to ${RHDH_POD}:7007 on localhost:${LOCAL_PORT}"
oc port-forward -n "${NS}" "${RHDH_POD}" "${LOCAL_PORT}:7007" &
PF_PID=$!
sleep 3

RHDH_URL="http://localhost:${LOCAL_PORT}"
cleanup() { kill "${PF_PID}" 2>/dev/null || true; }
trap cleanup EXIT

# ── Step 3: Verify connectivity ──
echo "==> Verifying RHDH API connectivity"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${RHDH_URL}/api/permission/health" || echo "000")
if [[ "${HTTP_CODE}" != "200" ]]; then
  echo "WARNING: Health check returned ${HTTP_CODE}. RBAC plugin may not be enabled."
  echo "  Ensure permission.enabled: true in app-config."
fi

# ── Step 4: Create roles via RBAC REST API ──
echo ""
echo "==> Creating RBAC roles"
echo "    Creating role: platform-engineers"
curl -s -X POST "${RHDH_URL}/api/permission/roles" \
  -H "Content-Type: application/json" \
  -d '{
    "memberReferences": ["group:default/platform-engineering"],
    "name": "role:default/platform-engineers"
  }' || echo "    (role may already exist)"

echo ""
echo "    Creating role: developers"
curl -s -X POST "${RHDH_URL}/api/permission/roles" \
  -H "Content-Type: application/json" \
  -d '{
    "memberReferences": ["group:default/developers"],
    "name": "role:default/developers"
  }' || echo "    (role may already exist)"

echo ""
echo "    Creating role: viewers"
curl -s -X POST "${RHDH_URL}/api/permission/roles" \
  -H "Content-Type: application/json" \
  -d '{
    "memberReferences": [],
    "name": "role:default/viewers"
  }' || echo "    (role may already exist)"

# ── Step 5: Apply permission policies ──
echo ""
echo "==> Applying permission policies for platform-engineers"
curl -s -X POST "${RHDH_URL}/api/permission/policies" \
  -H "Content-Type: application/json" \
  -d '[
    {"entityReference":"role:default/platform-engineers","permission":"catalog.entity.read","policy":"read","effect":"allow"},
    {"entityReference":"role:default/platform-engineers","permission":"catalog.entity.create","policy":"create","effect":"allow"},
    {"entityReference":"role:default/platform-engineers","permission":"catalog.entity.delete","policy":"delete","effect":"allow"},
    {"entityReference":"role:default/platform-engineers","permission":"catalog.entity.refresh","policy":"update","effect":"allow"},
    {"entityReference":"role:default/platform-engineers","permission":"catalog.location.read","policy":"read","effect":"allow"},
    {"entityReference":"role:default/platform-engineers","permission":"catalog.location.create","policy":"create","effect":"allow"},
    {"entityReference":"role:default/platform-engineers","permission":"catalog.location.delete","policy":"delete","effect":"allow"},
    {"entityReference":"role:default/platform-engineers","permission":"scaffolder.action.execute","policy":"use","effect":"allow"},
    {"entityReference":"role:default/platform-engineers","permission":"scaffolder.template.parameter.read","policy":"read","effect":"allow"},
    {"entityReference":"role:default/platform-engineers","permission":"scaffolder.template.step.read","policy":"read","effect":"allow"},
    {"entityReference":"role:default/platform-engineers","permission":"policy-entity","policy":"read","effect":"allow"},
    {"entityReference":"role:default/platform-engineers","permission":"policy-entity","policy":"create","effect":"allow"},
    {"entityReference":"role:default/platform-engineers","permission":"policy-entity","policy":"update","effect":"allow"},
    {"entityReference":"role:default/platform-engineers","permission":"policy-entity","policy":"delete","effect":"allow"}
  ]'

echo ""
echo "==> Applying permission policies for developers"
curl -s -X POST "${RHDH_URL}/api/permission/policies" \
  -H "Content-Type: application/json" \
  -d '[
    {"entityReference":"role:default/developers","permission":"catalog.entity.read","policy":"read","effect":"allow"},
    {"entityReference":"role:default/developers","permission":"catalog.entity.create","policy":"create","effect":"allow"},
    {"entityReference":"role:default/developers","permission":"catalog.entity.refresh","policy":"update","effect":"allow"},
    {"entityReference":"role:default/developers","permission":"scaffolder.action.execute","policy":"use","effect":"allow"},
    {"entityReference":"role:default/developers","permission":"scaffolder.template.parameter.read","policy":"read","effect":"allow"},
    {"entityReference":"role:default/developers","permission":"scaffolder.template.step.read","policy":"read","effect":"allow"}
  ]'

echo ""
echo "==> Applying permission policies for viewers"
curl -s -X POST "${RHDH_URL}/api/permission/policies" \
  -H "Content-Type: application/json" \
  -d '[
    {"entityReference":"role:default/viewers","permission":"catalog.entity.read","policy":"read","effect":"allow"},
    {"entityReference":"role:default/viewers","permission":"scaffolder.template.parameter.read","policy":"read","effect":"allow"},
    {"entityReference":"role:default/viewers","permission":"scaffolder.template.step.read","policy":"read","effect":"allow"}
  ]'

# ── Step 6: Verify ──
echo ""
echo "==> Verifying roles"
curl -s "${RHDH_URL}/api/permission/roles" | python3 -m json.tool 2>/dev/null || echo "(install python3 for formatted output)"

echo ""
echo "=============================================="
echo " RBAC setup complete."
echo ""
echo " Key enforcement:"
echo "   - Developers CAN execute templates (scaffolder.action.execute)"
echo "   - Developers CANNOT register new templates (no catalog.location.create)"
echo "   - Developers CANNOT delete catalog entities (no catalog.entity.delete)"
echo "   - Viewers can only browse the catalog and view templates"
echo "=============================================="
