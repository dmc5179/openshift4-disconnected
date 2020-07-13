#!/bin/bash
  
# Source the environment file with the default settings
. ./env.sh

MANIFESTS=""

if [ "${RH_OP}" = true ]
then

  MANIFESTS="redhat-operators-manifests"

fi

if [ "${CERT_OP}" = true ]
then

  MANIFESTS="${MANIFESTS} certified-operators-manifests"

fi

if [ "${COMM_OP}" = true ]
then

  MANIFESTS="${MANIFESTS} community-operators-manifests"

fi

# Don't quote MANIFESTS since it could be 3 directories
tar -cf operators_hub.tar "${DATA_DIR}" ${MANIFESTS}

exit 0
