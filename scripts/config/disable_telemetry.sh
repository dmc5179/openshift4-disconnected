#!/bin/bash
#
# Disable remote health reporting on a disconnected OpenShift 4 cluster.
#
# Despite the filename, this does three things, because the pull-secret edit on
# its own is no longer sufficient on current z-streams:
#
#   1. openshift-monitoring/cluster-monitoring-config -> telemeterClient.enabled: false
#        Must happen BEFORE step 2. Removing cloud.openshift.com while the telemeter
#        client is still enabled drives the console cluster operator into
#        ConfigMapSyncDegraded / FailedGetTelemetryConfig.
#        Solution 7144676, OCPBUGS-87348.
#
#   2. openshift-config/pull-secret -> remove the cloud.openshift.com entry
#        The documented opt-out. OCP 4.22 Support guide section 4.3.4; note the docs
#        are explicit that this disables BOTH Telemetry and the Insights Operator
#        reporting. The Insights Operator itself stays deployed -- it is part of the
#        release payload. Removing it entirely is an install-time decision
#        (capabilities.baselineCapabilitySet, cannot be undone post-install).
#
#   3. openshift-insights/insights-config -> dataReporting.disableRuntimeExtractor: true
#        The insights-runtime-extractor DaemonSet keeps running on every node even
#        after 1 and 2, burning CPU/memory. Requires 4.22.1+ / 4.21.20+ / 4.20.26+ /
#        4.19.36+. Solution 7143747.
#
# Existing ConfigMaps are MERGED, never overwritten -- cluster-monitoring-config in
# particular often already carries retention, storage and nodeSelector settings that
# an `oc apply` would destroy. Merging needs yq v4 (mikefarah). Without it, an
# already-present ConfigMap is left alone and the required stanza is printed instead.
#
# Deliberately NOT set: enableUserWorkload. Solution 7144676's example snippet
# includes it, but that is incidental to that customer's cluster -- setting it here
# would switch on user workload monitoring as a side effect.
#
# Do NOT use spec.overrides on the ClusterVersion object to remove any of these
# components. That puts the cluster in an unsupported state and blocks upgrades.

set -euo pipefail

for bin in oc jq; do
  if ! command -v "${bin}" >/dev/null 2>&1; then
    echo "ERROR: ${bin} not found in PATH. Install it and re-run." >&2
    exit 1
  fi
done

if ! oc whoami >/dev/null 2>&1; then
  echo "ERROR: not logged in to a cluster (oc whoami failed)." >&2
  exit 1
fi

workdir="$(mktemp -d)"
trap 'rm -rf "${workdir}"' EXIT

# yq v4 (mikefarah) and yq (python/jq-syntax) share a name but not a syntax, so
# probe behaviourally rather than parsing --version.
have_yq=false
if command -v yq >/dev/null 2>&1 \
   && printf 'a: 1\n' | yq eval '.b = 2' - 2>/dev/null | grep -q '^b: 2$'; then
  have_yq=true
fi

# set_config_key <namespace> <configmap> <yq-expression> <yaml-if-creating>
#
# Creates the ConfigMap with the given config.yaml body if absent, or merges the
# yq expression into the existing config.yaml if present. Skips with a warning if
# the namespace is missing (e.g. the monitoring stack was never installed).
set_config_key() {
  local ns="$1" cm="$2" expr="$3" body="$4"
  local current="${workdir}/${cm}.current.yaml"
  local merged="${workdir}/${cm}.merged.yaml"

  if ! oc get namespace "${ns}" >/dev/null 2>&1; then
    echo "  SKIP: namespace ${ns} does not exist."
    return 0
  fi

  if ! oc get configmap "${cm}" -n "${ns}" >/dev/null 2>&1; then
    echo "  ConfigMap ${ns}/${cm} does not exist -- creating it."
    printf '%s' "${body}" > "${merged}"
    oc create configmap "${cm}" -n "${ns}" --from-file=config.yaml="${merged}"
    return 0
  fi

  echo "  ConfigMap ${ns}/${cm} already exists -- merging."
  oc get configmap "${cm}" -n "${ns}" \
    -o jsonpath='{.data.config\.yaml}' > "${current}"

  if ! ${have_yq}; then
    echo "  SKIP: yq v4 (https://github.com/mikefarah/yq) not available, refusing to" >&2
    echo "        overwrite the existing config.yaml. Merge this in by hand:" >&2
    echo "" >&2
    printf '%s' "${body}" | sed 's/^/          /' >&2
    echo "" >&2
    return 0
  fi

  yq eval "${expr}" "${current}" > "${merged}"

  if diff -q "${current}" "${merged}" >/dev/null 2>&1; then
    echo "  Already set -- no change."
    return 0
  fi

  oc set data "configmap/${cm}" -n "${ns}" --from-file=config.yaml="${merged}"
}

# ---------------------------------------------------------------------------
echo "[1/3] Disabling the telemeter client (openshift-monitoring)..."
# ---------------------------------------------------------------------------
set_config_key \
  openshift-monitoring \
  cluster-monitoring-config \
  '.telemeterClient.enabled = false' \
  'telemeterClient:
  enabled: false
'

# ---------------------------------------------------------------------------
echo "[2/3] Removing the cloud.openshift.com entry from the global pull secret..."
# ---------------------------------------------------------------------------
# --confirm so a stale .dockerconfigjson in the target dir does not abort the run;
# the temp dir makes that unlikely, but it also keeps re-runs idempotent and keeps
# the credential out of the current working directory.
oc extract secret/pull-secret -n openshift-config --to="${workdir}" --confirm >/dev/null

if jq -e '.auths["cloud.openshift.com"]' "${workdir}/.dockerconfigjson" >/dev/null 2>&1; then
  jq 'del(.auths["cloud.openshift.com"])' "${workdir}/.dockerconfigjson" \
    > "${workdir}/.dockerconfigjson.tmp"
  mv "${workdir}/.dockerconfigjson.tmp" "${workdir}/.dockerconfigjson"
  oc set data secret/pull-secret -n openshift-config \
    --from-file=.dockerconfigjson="${workdir}/.dockerconfigjson"
  echo "  Removed. Allow several minutes for the secret to propagate."
else
  echo "  Already absent -- no change."
fi

# ---------------------------------------------------------------------------
echo "[3/3] Disabling the insights-runtime-extractor DaemonSet (openshift-insights)..."
# ---------------------------------------------------------------------------
# The flag is a no-op before the fix landed, so warn rather than imply success.
cluster_version="$(oc get clusterversion version -o jsonpath='{.status.desired.version}' 2>/dev/null || true)"
if [[ -n "${cluster_version}" ]]; then
  minor="${cluster_version%.*}"
  case "${minor}" in
    4.19) min_fix="4.19.36" ;;
    4.20) min_fix="4.20.26" ;;
    4.21) min_fix="4.21.20" ;;
    4.22) min_fix="4.22.1"  ;;
    *)    min_fix=""        ;;
  esac

  if [[ -n "${min_fix}" ]] \
     && [[ "$(printf '%s\n%s\n' "${min_fix}" "${cluster_version}" | sort -V | head -1)" != "${min_fix}" ]]; then
    echo "  WARNING: cluster is ${cluster_version}; disableRuntimeExtractor needs ${min_fix}+." >&2
    echo "           Writing the ConfigMap anyway -- it takes effect after the upgrade." >&2
  fi
fi

set_config_key \
  openshift-insights \
  insights-config \
  '.dataReporting.disableRuntimeExtractor = true' \
  'dataReporting:
  disableRuntimeExtractor: true
'

# ---------------------------------------------------------------------------
cat <<'EOF'

Done. Verify with:

  # Insights reporting off (expect Disabled=True / GatheringDisabled=True)
  oc get co insights -o jsonpath='{.status.conditions[?(@.type=="Disabled")]}{"\n"}'
  oc get co insights -o jsonpath='{.status.conditions[?(@.type=="GatheringDisabled")].status}{"\n"}'

  # Console operator did NOT go degraded (the OCPBUGS-87348 regression)
  oc get co console

  # Telemeter client gone
  oc get pods -n openshift-monitoring -l app.kubernetes.io/name=telemeter-client

  # Runtime extractor pods gone (known cleanup regression: OCPBUGS-87197)
  oc get pods -n openshift-insights -l app.kubernetes.io/name=insights-runtime-extractor

Note: the Insights Operator itself remains deployed. Removing it entirely requires
disabling the Insights cluster capability at install time, which cannot be done on a
running cluster.
EOF
