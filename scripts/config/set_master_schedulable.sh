#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Source the environment file with the default settings
source "${SCRIPT_DIR}/../env.sh"

# Set OpenShift internal registry to use the empty dir for storage
# Typically done in UPI installs when no default storage class is available
# Configure the registry to use storage when available

if test -z "$1"
then
  echo "true or false required"
  exit 1
fi

oc patch schedulers.config.openshift.io cluster --type merge --patch "{\"spec\":{\"mastersSchedulable\":$1}}"
