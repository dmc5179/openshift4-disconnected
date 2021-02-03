#!/bin/bash -xe

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Source the environment file with the default settings
source "${SCRIPT_DIR}/../env.sh"

set -x

${OC} image mirror \
  --registry-config=${LOCAL_SECRET_JSON} \
  --from-dir=${OCP_MEDIA_PATH}/mirror \
  "file://openshift/release:${OCP_RELEASE}*" \
  ${LOCAL_REG}/${LOCAL_REPO}

exit 0
