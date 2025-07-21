#!/bin/bash
set -o nounset
set -o errexit

PATCH='{"spec":{"devEnvironments":{"secondsOfInactivityBeforeIdling": -1}}}'

oc patch -n openshift-operators checluster devspaces \
  --type=merge -p \
  "${PATCH}"
