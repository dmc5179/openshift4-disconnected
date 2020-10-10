#!/bin/bash -xe

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  
# Source the environment file with the default settings
source "${SCRIPT_DIR}/../env.sh"

oc image mirror -a ${LOCAL_SECRET_JSON} \
--insecure=${LOCAL_REG_INSEC} \
--from-dir=${REMOVABLE_MEDIA_PATH}/mirror \
'file://openshift/release:${OCP_RELEASE}*' \
${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}
