#!/bin/bash
#
# Install the OpenShift Compliance Operator and run the DISA STIG profiles
# (ocp4-stig, ocp4-stig-node, rhcos4-stig) against the cluster.
#
# Run with --help for the full list of choices. See README.md in this
# directory for prerequisites, disconnected-cluster notes and cleanup.
#
# Reference: OCP 4.20 Security and compliance, "Installing the Compliance
# Operator using the CLI" and "Managing Compliance Operator remediation".
# Solution 7146831 covers default vs default-auto-apply.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NAMESPACE="openshift-compliance"
BINDING_NAME="stig-compliance"
PACKAGE="compliance-operator"
TAILORED_FILE="${SCRIPT_DIR}/profiles/rhcos4-stig-v2r6-with-sshd-enabled-tailored-profile.yaml"

MODE="report"
KEEP_SSHD=false
CATALOG=""
CHANNEL=""
WAIT_FOR_SCAN=true
ASSUME_YES=false
DRY_RUN=false
TIMEOUT=1800

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Installs the OpenShift Compliance Operator (if needed) and runs the DISA STIG
profiles for OpenShift (ocp4-stig, ocp4-stig-node) and RHCOS (rhcos4-stig).

MODE (pick one)
  -m, --mode report    Default. Scan only. Binds the profiles to the "default"
                       ScanSetting (autoApplyRemediations: false). Results and
                       proposed fixes show up as ComplianceCheckResults and
                       ComplianceRemediations. Nothing on the cluster is changed.
                       Uses: stig-compliance.yaml

  -m, --mode enforce   Scan and fix. Binds the profiles to "default-auto-apply"
                       (autoApplyRemediations: true). Fixes are applied as
                       MachineConfigs and KubeletConfigs, which REBOOTS EVERY
                       NODE. Switching back to report mode later does NOT undo
                       fixes that were already applied.
                       Uses: stig-compliance-remediate.yaml

SSH ACCESS
      --keep-sshd      Leave sshd running on the nodes. Creates the
                       TailoredProfile rhcos4-stig-v2r6-with-sshd-enabled,
                       which is rhcos4-stig-v2r6 minus the
                       rhcos4-service-sshd-disabled rule, and scans with it
                       instead of rhcos4-stig-v2r6.
                       Without this flag, enforce mode DISABLES sshd on all
                       nodes and you lose SSH access to them. In report mode
                       the flag just drops that one check from the results.
                       Uses: profiles/$(basename "${TAILORED_FILE}")

INSTALL SOURCE
  -c, --catalog NAME   CatalogSource in openshift-marketplace to install from.
                       Default: auto-detect. Prefers "redhat-operators"
                       (connected clusters), then any catalog with
                       "redhat-operator-index" in its name (oc-mirror creates
                       cs-redhat-operator-index or cs-redhat-operator-index-v4-XX).
      --channel NAME   Subscription channel. Default: the package's defaultChannel.

BEHAVIOR
      --dry-run        Change nothing. Detect the catalog, print the manifests,
                       and validate them with 'oc apply --dry-run=server'.
      --no-wait        Apply the binding and exit without waiting for results.
  -t, --timeout SEC    Max wait for each phase (default: ${TIMEOUT}).
  -y, --yes            Skip the confirmation prompt in enforce mode.
  -h, --help           Show this help.

EXAMPLES
  $(basename "$0")                          # report only
  $(basename "$0") --keep-sshd              # report, without the sshd check
  $(basename "$0") --mode enforce --keep-sshd   # enforce, keep SSH access
  $(basename "$0") --mode enforce --dry-run     # preview enforce, change nothing
  $(basename "$0") --catalog cs-redhat-operator-index-v4-22   # disconnected

Re-running is safe. Switching mode or --keep-sshd on an existing binding
updates it in place and triggers a rescan.
EOF
}

log()  { echo "==> $*"; }
warn() { echo "WARNING: $*" >&2; }
die()  { echo "ERROR: $*" >&2; exit 1; }

# wait_for DESCRIPTION COMMAND...
# Re-runs COMMAND every 10s until it succeeds or TIMEOUT expires.
wait_for() {
  local desc="$1"; shift
  local start=$SECONDS
  log "Waiting for ${desc} (timeout ${TIMEOUT}s)"
  until "$@" >/dev/null 2>&1; do
    if (( SECONDS - start >= TIMEOUT )); then
      die "Timed out waiting for ${desc}"
    fi
    sleep 10
  done
}

# Apply a manifest from stdin, or only validate it in --dry-run mode.
apply() {
  if [[ "${DRY_RUN}" == true ]]; then
    oc apply --dry-run=server -f -
  else
    oc apply -f -
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -m|--mode)     MODE="${2:-}"; shift 2 ;;
    --keep-sshd)   KEEP_SSHD=true; shift ;;
    -c|--catalog)  CATALOG="${2:-}"; shift 2 ;;
    --channel)     CHANNEL="${2:-}"; shift 2 ;;
    --dry-run)     DRY_RUN=true; shift ;;
    --no-wait)     WAIT_FOR_SCAN=false; shift ;;
    -t|--timeout)  TIMEOUT="${2:-}"; shift 2 ;;
    -y|--yes)      ASSUME_YES=true; shift ;;
    -h|--help)     usage; exit 0 ;;
    *)             usage >&2; die "Unknown option: $1" ;;
  esac
done

case "${MODE}" in
  report)  BINDING_FILE="${SCRIPT_DIR}/stig-compliance.yaml" ;;
  enforce) BINDING_FILE="${SCRIPT_DIR}/stig-compliance-remediate.yaml" ;;
  *)       die "--mode must be 'report' or 'enforce' (got '${MODE}')" ;;
esac
[[ -f "${BINDING_FILE}" ]] || die "Binding file not found: ${BINDING_FILE}"
[[ "${KEEP_SSHD}" != true || -f "${TAILORED_FILE}" ]] || die "TailoredProfile not found: ${TAILORED_FILE}"
[[ "${TIMEOUT}" =~ ^[0-9]+$ ]] || die "--timeout must be a number of seconds"

# --- Preflight ---------------------------------------------------------------

for bin in oc jq; do
  command -v "${bin}" >/dev/null 2>&1 || die "${bin} not found in PATH"
done
oc whoami >/dev/null 2>&1 || die "Not logged in to a cluster (oc whoami failed)"
[[ "$(oc auth can-i '*' '*' --all-namespaces 2>/dev/null)" == "yes" ]] \
  || die "cluster-admin privileges are required"

log "Cluster: $(oc whoami --show-server)  Mode: ${MODE}  Keep sshd: ${KEEP_SSHD}  Dry run: ${DRY_RUN}"

if [[ "${MODE}" == "enforce" && "${ASSUME_YES}" != true && "${DRY_RUN}" != true ]]; then
  echo
  echo "  Enforce mode binds the STIG profiles to the default-auto-apply ScanSetting."
  echo "  Remediations will be applied automatically as MachineConfigs, which"
  echo "  triggers rolling node reboots. Applied remediations are not reverted by"
  echo "  switching back to report mode."
  if [[ "${KEEP_SSHD}" == true ]]; then
    echo "  sshd will be LEFT RUNNING (--keep-sshd)."
  else
    echo "  sshd will be DISABLED on all nodes. Re-run with --keep-sshd to avoid this."
  fi
  echo
  read -r -p "Type 'enforce' to continue: " answer
  [[ "${answer}" == "enforce" ]] || die "Aborted"
fi

# --- Catalog / channel -------------------------------------------------------

catalog_has_package() {
  oc get packagemanifests -n openshift-marketplace -l "catalog=$1" -o name 2>/dev/null \
    | grep -qx "packagemanifest.packages.operators.coreos.com/${PACKAGE}"
}

if [[ -z "${CATALOG}" ]]; then
  # Connected clusters ship "redhat-operators" (built from redhat-operator-index).
  # oc-mirror names the mirrored copy cs-redhat-operator-index[-v4-XX].
  for cs in $(oc get catalogsource -n openshift-marketplace -o name | sed 's|.*/||' \
                | grep -E '^redhat-operators$|redhat-operator-index' | sort -r); do
    if catalog_has_package "${cs}"; then CATALOG="${cs}"; break; fi
  done
  [[ -n "${CATALOG}" ]] || die "No redhat-operators / redhat-operator-index CatalogSource \
providing ${PACKAGE} found. Use --catalog. Available: $(oc get catalogsource -n openshift-marketplace -o name | sed 's|.*/||' | xargs)"
else
  oc get catalogsource -n openshift-marketplace "${CATALOG}" >/dev/null 2>&1 \
    || die "CatalogSource ${CATALOG} not found in openshift-marketplace"
  catalog_has_package "${CATALOG}" || die "CatalogSource ${CATALOG} does not provide ${PACKAGE}"
fi

if [[ -z "${CHANNEL}" ]]; then
  CHANNEL="$(oc get packagemanifests -n openshift-marketplace -l "catalog=${CATALOG}" -o json \
    | jq -r --arg p "${PACKAGE}" '.items[] | select(.metadata.name == $p) | .status.defaultChannel')"
  [[ -n "${CHANNEL}" && "${CHANNEL}" != "null" ]] || CHANNEL="stable"
fi
log "Installing ${PACKAGE} from catalog ${CATALOG}, channel ${CHANNEL}"

# --- Operator install --------------------------------------------------------

apply <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: ${NAMESPACE}
  labels:
    openshift.io/cluster-monitoring: "true"
    pod-security.kubernetes.io/enforce: privileged
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: compliance-operator
  namespace: ${NAMESPACE}
spec:
  targetNamespaces:
  - ${NAMESPACE}
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: compliance-operator-sub
  namespace: ${NAMESPACE}
spec:
  channel: "${CHANNEL}"
  installPlanApproval: Automatic
  name: ${PACKAGE}
  source: ${CATALOG}
  sourceNamespace: openshift-marketplace
EOF

operator_installed=true
if [[ "${DRY_RUN}" == true ]]; then
  oc get crd scansettingbindings.compliance.openshift.io >/dev/null 2>&1 || operator_installed=false
else
  csv_succeeded() {
    local csv
    csv="$(oc get subscription compliance-operator-sub -n "${NAMESPACE}" -o jsonpath='{.status.installedCSV}')"
    [[ -n "${csv}" ]] || return 1
    [[ "$(oc get csv "${csv}" -n "${NAMESPACE}" -o jsonpath='{.status.phase}')" == "Succeeded" ]]
  }
  wait_for "Compliance Operator CSV to succeed" csv_succeeded
  log "Installed $(oc get subscription compliance-operator-sub -n "${NAMESPACE}" -o jsonpath='{.status.installedCSV}')"

  bundles_valid() {
    local b
    for b in ocp4 rhcos4; do
      [[ "$(oc get profilebundle "${b}" -n "${NAMESPACE}" -o jsonpath='{.status.dataStreamStatus}')" == "VALID" ]] \
        || return 1
    done
  }
  wait_for "ocp4 and rhcos4 ProfileBundles to be VALID" bundles_valid
fi

# --- Build the ScanSettingBinding --------------------------------------------

binding_json="$(oc create --dry-run=client -o json -f "${BINDING_FILE}")"

if [[ "${KEEP_SSHD}" == true ]]; then
  tailored_json="$(oc create --dry-run=client -o json -f "${TAILORED_FILE}")"
  tp_name="$(jq -r '.metadata.name' <<<"${tailored_json}")"
  tp_extends="$(jq -r '.spec.extends' <<<"${tailored_json}")"
  # Swap the profile the TailoredProfile extends for the TailoredProfile itself.
  jq -e --arg base "${tp_extends}" 'any(.profiles[]; .name == $base)' <<<"${binding_json}" >/dev/null \
    || die "$(basename "${TAILORED_FILE}") extends ${tp_extends}, which is not in $(basename "${BINDING_FILE}"). Update one so the versions match."
  binding_json="$(jq --arg base "${tp_extends}" --arg tp "${tp_name}" \
    '.profiles |= map(if .name == $base then .kind = "TailoredProfile" | .name = $tp else . end)' \
    <<<"${binding_json}")"
fi

# Profiles are versioned (v2r3, v2r6, ...) and older versions are dropped from
# newer content images, so check the binding's profiles actually exist.
if [[ "${operator_installed}" == true ]]; then
  missing=()
  for p in $(jq -r '.profiles[] | select(.kind == "Profile") | .name' <<<"${binding_json}") ${tp_extends:-}; do
    oc get profile.compliance.openshift.io "${p}" -n "${NAMESPACE}" >/dev/null 2>&1 || missing+=("${p}")
  done
  if (( ${#missing[@]} > 0 )); then
    die "Profile(s) not available in this operator version: ${missing[*]}
Available STIG profiles: $(oc get profiles.compliance.openshift.io -n "${NAMESPACE}" -o name | sed 's|.*/||' | grep stig | xargs)
Update the profile names in $(basename "${BINDING_FILE}")${tp_extends:+ and $(basename "${TAILORED_FILE}")}."
  fi
fi

if [[ "${DRY_RUN}" == true ]]; then
  if [[ "${KEEP_SSHD}" == true ]]; then
    log "TailoredProfile that would be applied:"
    cat "${TAILORED_FILE}"
  fi
  log "ScanSettingBinding that would be applied:"
  jq . <<<"${binding_json}"
  if [[ "${operator_installed}" == true ]]; then
    if [[ "${KEEP_SSHD}" == true ]]; then apply <"${TAILORED_FILE}"; fi
    apply <<<"${binding_json}"
  else
    log "Compliance Operator CRDs not installed yet; skipped server-side validation of the binding."
  fi
  log "Dry run complete. Nothing was changed."
  exit 0
fi

if [[ "${KEEP_SSHD}" == true ]]; then
  log "Applying TailoredProfile ${tp_name}"
  apply <"${TAILORED_FILE}"
  tailored_ready() {
    [[ "$(oc get tailoredprofile "${tp_name}" -n "${NAMESPACE}" -o jsonpath='{.status.state}')" == "READY" ]]
  }
  wait_for "TailoredProfile ${tp_name} to be READY" tailored_ready
fi

# Fingerprint of ScanSetting + profiles, so we know when the binding changes.
fingerprint='{s: .settingsRef.name, p: [.profiles[].name]}'
previous="$(oc get scansettingbinding "${BINDING_NAME}" -n "${NAMESPACE}" -o json 2>/dev/null \
  | jq -c "${fingerprint}" || true)"

log "Applying ScanSettingBinding ${BINDING_NAME} ($(basename "${BINDING_FILE}"), keep sshd: ${KEEP_SSHD})"
apply <<<"${binding_json}"
current="$(jq -c "${fingerprint}" <<<"${binding_json}")"

# A new ScanSetting or profile list only takes effect on the next scan, so
# force one when changing an existing binding.
if [[ -n "${previous}" && "${previous}" != "${current}" ]]; then
  log "Binding changed ${previous} -> ${current}; triggering rescan"
  sleep 10
  for scan in $(oc get compliancesuite "${BINDING_NAME}" -n "${NAMESPACE}" -o jsonpath='{.spec.scans[*].name}'); do
    oc annotate compliancescan "${scan}" -n "${NAMESPACE}" compliance.openshift.io/rescan= --overwrite || true
  done
fi

if [[ "${WAIT_FOR_SCAN}" != true ]]; then
  log "Not waiting for results. Check progress with:"
  echo "    oc get compliancesuite,compliancescan -n ${NAMESPACE}"
  exit 0
fi

# --- Results -----------------------------------------------------------------

suite_done() {
  [[ "$(oc get compliancesuite "${BINDING_NAME}" -n "${NAMESPACE}" -o jsonpath='{.status.phase}')" == "DONE" ]]
}
# Give the operator a moment to move the suite out of DONE after a rescan.
sleep 15
wait_for "ComplianceSuite ${BINDING_NAME} to reach DONE" suite_done

echo
oc get compliancesuite "${BINDING_NAME}" -n "${NAMESPACE}" -o json \
  | jq -r '(["SCAN", "PHASE", "RESULT"] | @tsv),
           (.status.scanStatuses[] | [.name, .phase, .result] | @tsv)' \
  | column -t
echo

oc get compliancecheckresults -n "${NAMESPACE}" \
  -l "compliance.openshift.io/suite=${BINDING_NAME}" -o json \
  | jq -r '
      .items
      | group_by(.metadata.labels["compliance.openshift.io/scan-name"])
      | (["SCAN", "PASS", "FAIL", "MANUAL", "INFO", "OTHER"] | @tsv),
        (.[] | . as $g
         | [ $g[0].metadata.labels["compliance.openshift.io/scan-name"],
             ([$g[] | select(.status == "PASS")]   | length),
             ([$g[] | select(.status == "FAIL")]   | length),
             ([$g[] | select(.status == "MANUAL")] | length),
             ([$g[] | select(.status == "INFO")]   | length),
             ([$g[] | select(.status | IN("PASS","FAIL","MANUAL","INFO") | not)] | length) ]
         | @tsv)' \
  | column -t

total_rem="$(oc get complianceremediations -n "${NAMESPACE}" \
  -l "compliance.openshift.io/suite=${BINDING_NAME}" -o name | wc -l)"
applied_rem="$(oc get complianceremediations -n "${NAMESPACE}" \
  -l "compliance.openshift.io/suite=${BINDING_NAME}" -o json \
  | jq '[.items[] | select(.spec.apply == true)] | length')"
echo
log "Remediations available: ${total_rem}, applied: ${applied_rem}"

cat <<EOF

Useful follow-ups (see README.md for more):
  # Failed checks with no automated remediation (must be fixed manually)
  oc get compliancecheckresults -n ${NAMESPACE} -l 'compliance.openshift.io/check-status=FAIL,!compliance.openshift.io/automated-remediation'

  # Review a remediation before applying it
  oc get complianceremediation <name> -n ${NAMESPACE} -o yaml

  # Apply a single remediation while staying in report mode
  oc patch complianceremediation <name> -n ${NAMESPACE} --type=merge -p '{"spec":{"apply":true}}'
EOF

if [[ "${MODE}" == "enforce" ]]; then
  cat <<EOF

Enforce mode: nodes will roll as MachineConfigs render. Watch with
  oc get mcp -w
then rescan once all pools are UPDATED:
  for s in \$(oc get compliancesuite ${BINDING_NAME} -n ${NAMESPACE} -o jsonpath='{.spec.scans[*].name}'); do
    oc annotate compliancescan \$s -n ${NAMESPACE} compliance.openshift.io/rescan= --overwrite; done
EOF
fi
