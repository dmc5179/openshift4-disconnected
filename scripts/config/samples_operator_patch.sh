#!/bin/bash -xe

#SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Source the environment file with the default settings
#source "${SCRIPT_DIR}/../env.sh"

oc patch configs.samples.operator.openshift.io cluster --type='merge' -p='{"spec":{"managementState":"Removed"}}'
