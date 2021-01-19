#!/bin/bash -xe
export OC="oc"
export COREOS_INSTALLER="coreos-installer"
export OCP_RELEASE="4.6.9"
export RHCOS_VER="4.6.8"
export ARCH="x86_64"
# Example: aws, metal
export PLATFORM="aws"
export UPSTREAM_REPO='openshift-release-dev'
# Directory where OCP images are written to or read from
# When mirroring to disk
export MEDIA_PATH="/opt/data/openshift"
export OCP_MEDIA_PATH="${MEDIA_PATH}/ocp-${OCP_RELEASE}"
export RHCOS_MEDIA_PATH="${MEDIA_PATH}/rhcos-${OCP_RELEASE}"
export LOCAL_SECRET_JSON="${HOME}/pull-secret.txt"
export RELEASE_NAME="ocp-release"

# Set these values to true for the catalog and miror to be created
export RH_OP='false'
export CERT_OP='false'
export COMM_OP='false'

export RH_OP_INDEX="registry.redhat.io/redhat/redhat-operator-index:v${OCP_RELEASE::3}"
export CERT_OP_INDEX="registry.redhat.io/redhat/certified-operator-index:v${OCP_RELEASE::3}"
export COMM_OP_INDEX="registry.redhat.io/redhat/community-operator-index:v${OCP_RELEASE::3}"

export OPERATOR_REGISTRY="quay.io/openshift-release-dev/ocp-release:${OCP_RELEASE}-${ARCH}"

function printhelp()
{
   echo "$0: -r"
   echo "-r  Pull Red Hat Operator Images"
   exit 0
}

while getopts rh flag
do
    case "${flag}" in
        r) RH_OP=true;;
        h) printhelp;;
    esac
done

mkdir -p "${OCP_MEDIA_PATH}/mirror"
mkdir -p "${RHCOS_MEDIA_PATH}"

echo "Mirroring cluster images"
${OC} adm release mirror -a ${LOCAL_SECRET_JSON} \
  --from=quay.io/${UPSTREAM_REPO}/${RELEASE_NAME}:${OCP_RELEASE}-${ARCH} \
  --to file://openshift/release \
  --to-dir=${OCP_MEDIA_PATH}/mirror

#echo "Pulling RHCOS Bits"
#${COREOS_INSTALLER} download --architecture "${ARCH}" --platform "${PLATFORM}" \
#  --stream "${RHCOS_VER}" --directory "${RHCOS_MEDIA_PATH}"

# Mirror redhat-operator index image
if [ "${RH_OP}" = true ]
then

  ${OC} image mirror \
    --dir=${OCP_MEDIA_PATH}/mirror \
    --registry-config=${LOCAL_SECRET_JSON} \
    --keep-manifest-list=true --filter-by-os=".*" \
    registry.redhat.io/redhat/redhat-operator-index:v${OCP_RELEASE::3} \
    file://redhat/redhat-operator-index:v${OCP_RELEASE::3}

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

fi

if [ "${CERT_OP}" = true ]
then

  ${OC} image mirror \
    --dir=${OCP_MEDIA_PATH}/mirror \
    --registry-config=${LOCAL_SECRET_JSON} \
    --keep-manifest-list=true --filter-by-os=".*"
    registry.redhat.io/redhat/certified-operator-index:v${OCP_RELEASE::3} \
    file://redhat/certified-operator-index:v${OCP_RELEASE::3}

  mkdir -p "${OCP_MEDIA_PATH}/certified_operators_manifests"

  ${OC} adm catalog mirror --manifests-only \
    --registry-config ${LOCAL_SECRET_JSON} \
    --to-manifests=${OCP_MEDIA_PATH}/certified_operators_manifests \
    ${CERT_OP_INDEX} replaceme

  sed -i 's|=replaceme/|=file://|g' ${OCP_MEDIA_PATH}/certified_operators_manifests/mapping.txt

  ${OC} image mirror \
    --keep-manifest-list=true --filter-by-os=".*"
    --registry-config=${LOCAL_SECRET_JSON} \
    --dir="${OCP_MEDIA_PATH}/mirror" \
    --filename=${OCP_MEDIA_PATH}/certified_operators_manifests/mapping.txt

fi

if [ "${COMM_OP}" = true ]
then

  ${OC} image mirror \
    --dir=${OCP_MEDIA_PATH}/mirror \
    --registry-config=${LOCAL_SECRET_JSON} \
    --keep-manifest-list=true --filter-by-os=".*"
    registry.redhat.io/redhat/community-operator-index:v${OCP_RELEASE::3} \
    file://redhat/community-operator-index:v${OCP_RELEASE::3}

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
fi

exit 0
