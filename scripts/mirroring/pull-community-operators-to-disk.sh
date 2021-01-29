#!/bin/bash -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Source the environment file with the default settings
source "${SCRIPT_DIR}/../env.sh"

set -x

#############################################################

mkdir -p "${OCP_MEDIA_PATH}/mirror"
mkdir -p "${RHCOS_MEDIA_PATH}"

${OC} image mirror \
  --dir=${OCP_MEDIA_PATH}/mirror \
  --registry-config=${LOCAL_SECRET_JSON} \
  --keep-manifest-list=true --filter-by-os=".*" \
  registry.redhat.io/redhat/community-operator-index:v${OCP_RELEASE::3} \
  file://redhat/community-operator-index

mkdir -p "${OCP_MEDIA_PATH}/community_operators_manifests"

${OC} adm catalog mirror --manifests-only \
  --registry-config ${LOCAL_SECRET_JSON} \
  --to-manifests=${OCP_MEDIA_PATH}/community_operators_manifests \
  ${COMM_OP_INDEX} replaceme

sed -i 's|=replaceme/|=file://|g' ${OCP_MEDIA_PATH}/community_operators_manifests/mapping.txt

${OC} image mirror \
  --keep-manifest-list=true --filter-by-os=".*"
  --registry-config=${LOCAL_SECRET_JSON} \
  --dir="${OCP_MEDIA_PATH}/mirror" \
  --filename=${OCP_MEDIA_PATH}/community_operators_manifests/mapping.txt

exit 0
