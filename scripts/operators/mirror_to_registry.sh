#!/bin/bash -xe

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  
# Source the environment file with the default settings
source "${SCRIPT_DIR}/../env.sh"

# Script for mirroring the operator hub images. Using oc adm catalog mirror to do the actual image
# mirroring is very slow. Here we grab the manifests and then use oc image mirror to multithread the copy

THREADS=4

#cp "${MANIFEST_PATH}/mapping.txt" "${MANIFEST_PATH}/mapping.txt.orig"
#sed -i "s|${LOCAL_REG}|s3://s3.amazonaws.com/${AWS_DEFAULT_REGION}/${S3_BUCKET}/${S3_BUCKET_PATH}|g" "${MANIFEST_PATH}/mapping.txt"

if [ "${RH_OP}" = true ]
then
  
  RH_OP_MANIFEST_PATH="/tmp/redhat-operator-manifests"

  rm -rf "${RH_OP_MANIFEST_PATH}"
  mkdir "${RH_OP_MANIFEST_PATH}"

  # Edit the mirroring mappings and mirror with "oc image mirror" manually
  # Have to have a registry running somewhere just so this command can authenticate to it
  # and then do nothing
  oc adm catalog mirror --manifests-only \
    --registry-config "${LOCAL_SECRET_JSON}" \
    --insecure=true --to-manifests=${RH_OP_MANIFEST_PATH} "${RH_OP_REPO}" "${LOCAL_REG}"

  cat "${RH_OP_MANIFEST_PATH}/mapping.txt" | xargs -n 1 -P ${THREADS} oc image mirror --registry-config "${LOCAL_SECRET_JSON}" --insecure=true '{}'

fi

if [ "${CERT_OP}" = true ]
then

  CERT_OP_MANIFEST_PATH="/tmp/certified-operator-manifests"

  rm -rf "${CERT_OP_MANIFEST_PATH}"
  mkdir "${CERT_OP_MANIFEST_PATH}"

  # Edit the mirroring mappings and mirror with "oc image mirror" manually
  # Have to have a registry running somewhere just so this command can authenticate to it
  # and then do nothing
  oc adm catalog mirror --manifests-only \
    --registry-config "${LOCAL_SECRET_JSON}" \
    --insecure=true --to-manifests=${CERT_OP_MANIFEST_PATH} "${CERT_OP_REPO}" "${LOCAL_REG}"

  cat "${CERT_OP_MANIFEST_PATH}/mapping.txt" | xargs -n 1 -P ${THREADS} oc image mirror --registry-config "${LOCAL_SECRET_JSON}" --insecure=true '{}'

fi

if [ "${COMM_OP}" = true ]
then

  COMM_OP_MANIFEST_PATH="/tmp/community-operator-manifests"

  rm -rf "${COMM_OP_MANIFEST_PATH}"
  mkdir "${COMM_OP_MANIFEST_PATH}"

  # Edit the mirroring mappings and mirror with "oc image mirror" manually
  # Have to have a registry running somewhere just so this command can authenticate to it
  # and then do nothing
  oc adm catalog mirror --manifests-only \
    --registry-config "${LOCAL_SECRET_JSON}" \
    --insecure=true --to-manifests=${COMM_OP_MANIFEST_PATH} "${COMM_OP_REPO}" "${LOCAL_REG}"

  cat "${COMM_OP_MANIFEST_PATH}/mapping.txt" | xargs -n 1 -P ${THREADS} oc image mirror --registry-config "${LOCAL_SECRET_JSON}" --insecure=true '{}'

fi

exit 0
