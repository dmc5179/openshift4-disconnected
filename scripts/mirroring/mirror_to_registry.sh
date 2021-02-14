#!/bin/bash -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  
# Source the environment file with the default settings
source "${SCRIPT_DIR}/../env.sh"

set -x

${OC} adm release mirror -a ${LOCAL_SECRET_JSON} \
--insecure=${LOCAL_REG_INSEC} \
--from=quay.io/${UPSTREAM_REPO}/${RELEASE_NAME}:${OCP_RELEASE}-${OCP_ARCH} \
--to-release-image=${LOCAL_REG}/${LOCAL_REPO}:${OCP_RELEASE}-${OCP_ARCH} \
--to=${LOCAL_REG}/${LOCAL_REPO}
