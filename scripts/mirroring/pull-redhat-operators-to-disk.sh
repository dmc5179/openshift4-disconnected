#!/bin/bash -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Source the environment file with the default settings
source "${SCRIPT_DIR}/../env.sh"

set -x

#############################################################

mkdir -p "${OCP_MEDIA_PATH}/mirror"
mkdir -p "${RHCOS_MEDIA_PATH}"

# Mirror redhat-operator index image

${OC} image mirror \
  --dir=${OCP_MEDIA_PATH}/mirror \
  --registry-config=${LOCAL_SECRET_JSON} \
  --keep-manifest-list=true --filter-by-os=".*" \
  registry.redhat.io/redhat/redhat-operator-index:v${OCP_RELEASE::3} \
  file://redhat/redhat-operator-index

${OC} image mirror \
  --dir=${OCP_MEDIA_PATH}/mirror \
  --registry-config=${LOCAL_SECRET_JSON} \
  --keep-manifest-list=true --filter-by-os=".*" \
  registry.redhat.io/redhat/redhat-marketplace-index:v${OCP_RELEASE::3} \
  file://redhat/redhat-marketplace-index

rm -rf "${OCP_MEDIA_PATH}/redhat_operators_manifests"
mkdir -p "${OCP_MEDIA_PATH}/redhat_operators_manifests"

${OC} adm catalog mirror --manifests-only \
  --registry-config ${LOCAL_SECRET_JSON} \
  --to-manifests=${OCP_MEDIA_PATH}/redhat_operators_manifests \
  ${RH_OP_INDEX} replaceme

sed -i 's|=replaceme/|=file://|g' ${OCP_MEDIA_PATH}/redhat_operators_manifests/mapping.txt

# Temporary fix due to a bug in the most recent redhat-operators-index image
sed -i -e 's/registry-proxy.engineering.redhat.com\/rh-osbs/registry.redhat.io/g' ${OCP_MEDIA_PATH}/redhat_operators_manifests/mapping.txt

sed -i '/serverless-operator:v1.0.0/d' ${OCP_MEDIA_PATH}/redhat_operators_manifests/mapping.txt
sed -i '/sha256:473d6dfb011c69f/d' ${OCP_MEDIA_PATH}/redhat_operators_manifests/mapping.txt

${OC} image mirror \
  --keep-manifest-list=true --filter-by-os=".*" \
  --registry-config=${LOCAL_SECRET_JSON} \
  --dir="${OCP_MEDIA_PATH}/mirror" \
  --filename=${OCP_MEDIA_PATH}/redhat_operators_manifests/mapping.txt

exit 0
