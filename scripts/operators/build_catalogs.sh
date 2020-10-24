#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  
# Source the environment file with the default settings
source "${SCRIPT_DIR}/../env.sh"

if [ "${RH_OP}" = true ]
then

  echo "Building redhat-operators catalog image"
  ${OC} adm catalog build --insecure \
      --registry-config=${LOCAL_SECRET_JSON} \
      --appregistry-org redhat-operators "--to=${RH_OP_REPO}" \
      "--from=${OPERATOR_REGISTRY}" "--registry-config=${LOCAL_SECRET_JSON}"

fi

if [ "${CERT_OP}" = true ]
then

  echo "Building certified operators catalog image"
  ${OC} adm catalog build --insecure \
      --registry-config=${LOCAL_SECRET_JSON} \
      --appregistry-org certified-operators "--to=${CERT_OP_REPO}" \
      "--from=${OPERATOR_REGISTRY}" "--registry-config=${LOCAL_SECRET_JSON}"

fi

if [ "${COMM_OP}" = true ]
then

  echo "Building community operators catalog image"
  "${OC}" adm catalog build --insecure \
      --registry-config=${LOCAL_SECRET_JSON} \
      --appregistry-org community-operators "--to=${COMM_OP_REPO}" \
      "--from=${OPERATOR_REGISTRY}" "--registry-config=${LOCAL_SECRET_JSON}"

fi

exit 0
