#!/bin/bash
export OCP_RELEASE="4.3.21-x86_64"
#export LOCAL_REG='registry.ocp4.example.com:5000'
export LOCAL_REG='localhost:5000'
export LOCAL_REPO='ocp4/openshift4'
export UPSTREAM_REPO='openshift-release-dev'

# This needs to be a pull secret that combines the pull secret from Red Hat
# to pull all the images down and a pull secret from your local registry so we
# can push to it
export LOCAL_SECRET_JSON="${HOME}/pull-secret.json"
#export RELEASE_NAME="ocp-release-nightly"
export RELEASE_NAME="ocp-release"

export RH_OP_REPO="${LOCAL_REG}/olm/redhat-operators:v1"
export CERT_OP_REPO="${LOCAL_REG}/olm/certified-operators:v1"
export COMM_OP_REPO="${LOCAL_REG}/olm/community-operators:v1"

export OPERATOR_REGISTRY='quay.io/operator-framework/operator-registry-server:v1.6.1'

echo "Building redhat-operators catalog image"
/usr/local/bin/oc adm catalog build --insecure \
    --appregistry-org redhat-operators "--to=${RH_OP_REPO}" \
    "--from=${OPERATOR_REGISTRY}" "--registry-config=${LOCAL_SECRET_JSON}"

echo "Building certified operators catalog image"
/usr/local/bin/oc adm catalog build --insecure \
    --appregistry-org certified-operators "--to=${CERT_OP_REPO}" \
    "--from=${OPERATOR_REGISTRY}" "--registry-config=${LOCAL_SECRET_JSON}"

echo "Building community operators catalog image"
/usr/local/bin/oc adm catalog build --insecure \
    --appregistry-org community-operators "--to=${COMM_OP_REPO}" \
    "--from=${OPERATOR_REGISTRY}" "--registry-config=${LOCAL_SECRET_JSON}"

echo "Mirroring redhat-operators catalog"
/usr/local/bin/oc adm catalog mirror ${RH_OP_REPO} ${LOCAL_REG} -a ${LOCAL_SECRET_JSON} --insecure

echo "Mirroring certified-operators catalog"
/usr/local/bin/oc adm catalog mirror ${CERT_OP_REPO} ${LOCAL_REG} -a ${LOCAL_SECRET_JSON} --insecure

#echo "Mirroring community-operators catalog"
#/usr/local/bin/oc adm catalog mirror ${COMM_OP_REPO} ${LOCAL_REG} -a ${LOCAL_SECRET_JSON} --insecure

exit 0
