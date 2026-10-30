#!/bin/bash
#
# Print the operator-0 ImageContentSourcePolicy from every results-* dir of an
# oc-mirror v1 workspace. Each sequential v1 run writes its own ICSP named
# operator-0, so applying them one after another overwrites the previous run.
#
# Incomplete. Need to merge the files together or just not have them all named operator-0
#
# Usage: merge-icsp.sh [oc-mirror-workspace dir]   (default: ./oc-mirror-workspace)

WORKSPACE="${1:-oc-mirror-workspace}"

for icsp in $(find "${WORKSPACE}"/results-* -name imageContentSourcePolicy.yaml)
do

  yq '. | select(.metadata.name == "operator-0")' "${icsp}"

done
