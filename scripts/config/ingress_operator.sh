#!/bin/bash -xe

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Source the environment file with the default settings
source "${SCRIPT_DIR}/../env.sh"

# Configure the replica set of the ingress operator

${OC} patch -n openshift-ingress-operator ingresscontroller/default --patch "{\"spec\":{\"replicas\": $1}}" --type=merge
