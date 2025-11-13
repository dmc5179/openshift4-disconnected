#!/bin/bash -xe

# Pull secret with auth to the offline registry
PULL_SECRET=/home/ec2-user/quay-mirror-auth.json
OCP_VERSION=4.19.13
ARCH=x86_64
PRIVATE_REGISTRY="ip-10-0-104-9.us-east-2.compute.internal:8443"

MODE="v2"  # Replace with v1 for oc-mirror v1 mode

# V1 Example
OC_MIRROR_WORKING_DIR="/home/ec2-user/oc-mirror-workspace"
# V2 Example
OC_MIRROR_WORKING_DIR="/home/ec2-user/download1/working-dir"

idms_location="cluster-resources/idms-oc-mirror.yaml"
icsp_location="results-1757018271/imageContentSourcePolicy.yaml"

IDMS_TMP=$(mktemp)

# Use this to get the IDMS for extract out of the oc-mirror metadata files on the registry server
yq '. | select(.metadata.name == "idms-release-0")' "${OC_MIRROR_WORKING_DIR}/${idms_location}" > ${IDMS_TMP}

if [[ ${MODE} == "v1" ]]
then
  ICSP_TMP=$(mktemp)
  # Use this to get the ICSP for extract out of the oc-mirror metadata files on the registry server
  yq '. | select(.metadata.name == "release-0")' "${OC_MIRROR_WORKING_DIR}/${icsp_location}" > ${ICSP_TMP}

cat <<EOF > ${IDMS_TMP}
apiVersion: config.openshift.io/v1
kind: ImageDigestMirrorSet
metadata:
  name: idms-release-0
spec:
  imageDigestMirrors:
EOF

  yq '.spec.repositoryDigestMirrors' ${ICSP_TMP} | sed 's|^|  |g' >> ${IDMS_TMP}

  rm -f ICSP_TMP

fi


# Extracts all the tools but this does not include openshift-install-fips which it should. Bug? Engineering says this is not a bug
oc adm release extract -a ${PULL_SECRET} --idms-file=${IDMS_TMP} --tools "${PRIVATE_REGISTRY}/openshift/release-images:${OCP_VERSION}-${ARCH}"

oc adm release extract -a ${PULL_SECRET} --idms-file=${IDMS_TMP} --command=openshift-install-fips "${PRIVATE_REGISTRY}/openshift/release-images:${OCP_VERSION}-${ARCH}"

rm -f ${IDMS_TMP}
exit 0
