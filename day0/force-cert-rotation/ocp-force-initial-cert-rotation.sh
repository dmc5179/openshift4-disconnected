#!/bin/bash
#
# List the secrets that hold the install-time certificates which have to be
# forced through their first rotation (see README.md) before a cluster is
# shut down or hibernated: aggregator-client, aggregator-client-signer,
# csr-signer (x2) and csr-signer-signer.
#
# They are found by expiry date. The initial csr-signer and aggregator-client*
# certs expire together, and csr-signer-signer expires later (on OCP 4.22,
# 2026-11-28 vs 2026-12-28 for a cluster installed 2026-10-28), so both
# dates are matched.
#
# Report only: the delete lines below are commented out on purpose.
#
# Usage: ocp-force-initial-cert-rotation.sh [YYYY-MM-DD ...]
#   With no arguments, the dates are read from the certificate-not-after
#   annotations of csr-signer and csr-signer-signer in
#   openshift-kube-controller-manager-operator. Pass one or more dates to
#   override them.

set -euo pipefail

ANNOTATION="auth.openshift.io/certificate-not-after"
NAMESPACES=(
  openshift-kube-apiserver
  openshift-kube-apiserver-operator
  openshift-kube-controller-manager
  openshift-kube-controller-manager-operator
)

# signer_not_after NAME: certificate-not-after of a kube-controller-manager-operator secret
signer_not_after() {
  oc get -n openshift-kube-controller-manager-operator secret "$1" -o json \
    | jq -r --arg a "${ANNOTATION}" '.metadata.annotations[$a] // empty'
}

if [[ $# -gt 0 ]]; then
  TARGET_DATES=("$@")
  for d in "${TARGET_DATES[@]}"; do
    [[ "${d}" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || { echo "ERROR: dates must be YYYY-MM-DD (got '${d}')" >&2; exit 1; }
  done
  echo "Using dates from arguments: ${TARGET_DATES[*]}"
else
  TARGET_DATES=()
  for signer in csr-signer csr-signer-signer; do
    na="$(signer_not_after "${signer}")"
    [[ -n "${na}" ]] || { echo "ERROR: ${signer} has no ${ANNOTATION} annotation; pass dates as arguments" >&2; exit 1; }
    echo "${signer} expires ${na}"
    TARGET_DATES+=("${na%%T*}")
  done
  echo "Matching: ${TARGET_DATES[*]}"
fi

i=1
for ns in "${NAMESPACES[@]}"
do
  echo "Checking ${ns} ${i}/${#NAMESPACES[@]}"
  # name<TAB>not-after for every secret in the namespace that carries the annotation
  while IFS=$'\t' read -r s not_after
  do
    echo "  ${s}: ${not_after}"
    for d in "${TARGET_DATES[@]}"; do
      if [[ "${not_after}" == "${d}"* ]]
      then
        echo "match: ${ns}    ${s}"
        #echo "Deleting: ${ns} ${s}"
        #oc delete -n "${ns}" secret "${s}"
      fi
    done
  done < <(oc get secrets -n "${ns}" -o json \
             | jq -r --arg a "${ANNOTATION}" '.items[] | select(.metadata.annotations[$a] != null) | "\(.metadata.name)\t\(.metadata.annotations[$a])"')
  i=$((i + 1))
done
