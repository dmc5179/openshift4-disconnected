#!/bin/bash -xe

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  
# Source the environment file with the default settings
source "${SCRIPT_DIR}/../env.sh"

MANIFEST_PATH="/tmp/redhat-operator-manifests"
S3_BUCKET='mybucket'
THREADS=4

rm -rf "${MANIFEST_PATH}"
mkdir "${MANIFEST_PATH}"

# Edit the mirroring mappings and mirror with "oc image mirror" manually
# Have to have a registry running somewhere just so this command can authenticate to it
# and then do nothing
${OC} adm catalog mirror --manifests-only \
  --registry-config "${LOCAL_SECRET_JSON}" \
  --insecure=true --to-manifests=${MANIFEST_PATH} "${RH_OP_REPO}" "${LOCAL_REG}"

cp "${MANIFEST_PATH}/mapping.txt" "${MANIFEST_PATH}/mapping.txt.orig"

sed -i "s|${LOCAL_REG}|s3://s3.amazonaws.com/${AWS_DEFAULT_REGION}/${S3_BUCKET}|g" "${MANIFEST_PATH}/mapping.txt"

cat "${MANIFEST_PATH}/mapping.txt" | xargs -n 1 -P ${THREADS} ${OC} image mirror --registry-config "${LOCAL_SECRET_JSON}" --insecure=true '{}'
