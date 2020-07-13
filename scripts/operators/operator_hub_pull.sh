#!/bin/bash

# Source the environment file with the default settings
. ./env.sh

if [ "${RH_OP}" = true ]
then
  echo "Building redhat-operators catalog image"
  /usr/local/bin/oc adm catalog build --insecure \
      --appregistry-org redhat-operators "--to=${RH_OP_REPO}" \
      "--from=${OPERATOR_REGISTRY}" "--registry-config=${LOCAL_SECRET_JSON}"

  echo "Mirroring redhat-operators catalog"
  /usr/local/bin/oc adm catalog mirror ${RH_OP_REPO} ${LOCAL_REG} -a ${LOCAL_SECRET_JSON} --insecure

fi

if [ "${CERT_OP}" = true ]
then
  echo "Building certified operators catalog image"
  /usr/local/bin/oc adm catalog build --insecure \
      --appregistry-org certified-operators "--to=${CERT_OP_REPO}" \
      "--from=${OPERATOR_REGISTRY}" "--registry-config=${LOCAL_SECRET_JSON}"

  echo "Mirroring certified-operators catalog"
  /usr/local/bin/oc adm catalog mirror ${CERT_OP_REPO} ${LOCAL_REG} -a ${LOCAL_SECRET_JSON} --insecure

fi

if [ "${COMM_OP}" = true ]
then
  echo "Building community operators catalog image"
  /usr/local/bin/oc adm catalog build --insecure \
      --appregistry-org community-operators "--to=${COMM_OP_REPO}" \
      "--from=${OPERATOR_REGISTRY}" "--registry-config=${LOCAL_SECRET_JSON}"

  echo "Mirroring community-operators catalog"
  /usr/local/bin/oc adm catalog mirror ${COMM_OP_REPO} ${LOCAL_REG} -a ${LOCAL_SECRET_JSON} --insecure

fi

exit 0



ec2-user@ip-10-0-13-142 danclark]$ ll redhat-operators-manifests/
total 288
-rwxrwxr-x. 1 ec2-user ec2-user 135090 Jul  9 23:32 imageContentSourcePolicy.yaml
-rw-rw-r--. 1 ec2-user ec2-user 157961 Jul  9 23:32 mapping.txt

