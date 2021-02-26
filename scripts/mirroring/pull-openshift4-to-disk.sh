#!/bin/bash -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Source the environment file with the default settings
source "${SCRIPT_DIR}/../env.sh"

set -x

#############################################################

mkdir -p "${OCP_MEDIA_PATH}/mirror"
mkdir -p "${RHCOS_MEDIA_PATH}"

echo "Mirroring cluster images"
${OC} adm release mirror -a ${LOCAL_SECRET_JSON} \
  --from=quay.io/${UPSTREAM_REPO}/${RELEASE_NAME}:${OCP_RELEASE}-${OCP_ARCH} \
  --to file://openshift/release \
  --to-dir=${OCP_MEDIA_PATH}/mirror

exit 0
