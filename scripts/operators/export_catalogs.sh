#!/bin/bash

# Script for exporting the OpenShift OperatorHub Catalog Source Images
# When needed for a disconnected/air-gap install

if ! test -e $(which skopeo)
then
  echo 'skopeo is required for this script'
  exit 1
fi


if [ "${RH_OP}" = true ]
then

  skopeo copy --authfile=${LOCAL_SECRET_JSON} \
         docker://${RH_OP_REPO} \
         docker-archive:redhat-operators_v1.tar

fi

if [ "${CERT_OP}" = true ]
then

  skopeo copy --authfile=${LOCAL_SECRET_JSON} \
         docker://${CERT_OP_REPO} \
         docker-archive:redhat-operators_v1.tar

fi

if [ "${COMM_OP}" = true ]
then

  skopeo copy --authfile=${LOCAL_SECRET_JSON} \
         docker://${COMM_OP_REPO} \
         docker-archive:redhat-operators_v1.tar

fi

exit 0
