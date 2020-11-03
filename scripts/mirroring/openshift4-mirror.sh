#!/bin/bash -xe
export OC="/usr/local/bin/oc-4.6.1"
export OCP_RELEASE="4.6.1"
export ARCHITECTURE="x86_64"
export LOCAL_REG='localhost:5000'
export LOCAL_REPO='ocp4/openshift4'
export LOCAL_REG_INSEC='true'
export UPSTREAM_REPO='openshift-release-dev'
export OCP_ARCH="x86_64"
# Directory where OCP images are written to or read from
# When mirroring to disk
export REMOVABLE_MEDIA_PATH="/opt/data/packed/ocp-${OCP_RELEASE}"

# Registry where cluster images live for the disconnected cluster
export REMOTE_REG="1234567890.dkr.ecr.us-east-1.amazonaws.com"

# This needs to be a pull secret that combines the pull secret from Red Hat
# to pull all the images down and a pull secret from your local registry so we
# can push to it
export LOCAL_SECRET_JSON="${HOME}/pull-secret.json"
export RELEASE_NAME="ocp-release"

# Set these values to true for the catalog and miror to be created
export RH_OP='true'
export CERT_OP='false'
export COMM_OP='false'

export RH_OP_INDEX="registry.redhat.io/redhat/redhat-operator-index:v${OCP_RELEASE::3}"
export CERT_OP_INDEX="registry.redhat.io/redhat/certified-operator-index:v${OCP_RELEASE::3}"
export COMM_OP_INDEX="registry.redhat.io/redhat/community-operator-index:v${OCP_RELEASE::3}"

#export OPERATOR_REGISTRY='quay.io/operator-framework/operator-registry-server:latest'
export OPERATOR_REGISTRY="quay.io/openshift-release-dev/ocp-release:${OCP_RELEASE}-${ARCHITECTURE}"

# This is either the directory backing the local podman registry, i.e; /opt/registry/data
# Or this is the directory where the images will be mirrored to/from if using --to-dir
export DATA_DIR="/opt/registry/data/docker/"

export THREADS=10

function printhelp()
{
   echo "Help me!"
   exit 0
}

UPLOAD=false
DOWNLOAD=false

while getopts udh flag
do
    case "${flag}" in
        u) UPLOAD=true;;
        d) DOWNLOAD=true;;
        h) printhelp;;
    esac
done

if [ "${DOWNLOAD}" = true ]
then

  mkdir -p "${REMOVABLE_MEDIA_PATH}/mirror"

  # Looks like this is working
  # Mirror the cluster images to disk
  echo "Mirroring cluster images"
  ${OC} adm release mirror -a ${LOCAL_SECRET_JSON} \
    --insecure=${LOCAL_REG_INSEC} \
    --max-per-registry=${THREADS} \
    --from=quay.io/${UPSTREAM_REPO}/${RELEASE_NAME}:${OCP_RELEASE}-${ARCHITECTURE} \
    --to file://openshift/release \
    --to-dir=${REMOVABLE_MEDIA_PATH}/mirror

  # Mirror redhat-operator index image
  if [ "${RH_OP}" = true ]
  then

    ${OC} image mirror \
      --dir=${REMOVABLE_MEDIA_PATH}/mirror \
      --registry-config=${LOCAL_SECRET_JSON} \
      --keep-manifest-list=true \
      --filter-by-os=.* \
      registry.redhat.io/redhat/redhat-operator-index:v${OCP_RELEASE::3} \
      file://redhat/redhat-operator-index:v${OCP_RELEASE::3}

    mkdir -p "${REMOVABLE_MEDIA_PATH}/redhat_operators_manifests"

    ${OC} adm catalog mirror --manifests-only \
      --max-per-registry=${THREADS} \
      --registry-config ${LOCAL_SECRET_JSON} \
      --to-manifests=${REMOVABLE_MEDIA_PATH}/redhat_operators_manifests \
      ${RH_OP_INDEX} replaceme

    sed -i 's|=replaceme/|=file://|g' ${REMOVABLE_MEDIA_PATH}/redhat_operators_manifests/mapping.txt

    ${OC} image mirror \
      '--filter-by-os=.*' \
      --keep-manifest-list=true \
      --max-per-registry=6 \
      --max-registry=4 \
      --registry-config=${LOCAL_SECRET_JSON} \
      --dir="${REMOVABLE_MEDIA_PATH}/mirror" \
      --filename=${REMOVABLE_MEDIA_PATH}/redhat_operators_manifests/mapping.txt

  fi

  if [ "${CERT_OP}" = true ]
  then
    ${OC} image mirror \
      --dir=${REMOVABLE_MEDIA_PATH}/mirror \
      --registry-config=${LOCAL_SECRET_JSON} \
      --keep-manifest-list=true \
      --filter-by-os=.* \
      registry.redhat.io/redhat/certified-operator-index:v${OCP_RELEASE::3} \
      file://redhat/certified-operator-index:v${OCP_RELEASE::3}

    mkdir -p "${REMOVABLE_MEDIA_PATH}/certified_operators_manifests"

    ${OC} adm catalog mirror --manifests-only \
      --max-per-registry=${THREADS} \
      --registry-config ${LOCAL_SECRET_JSON} \
      --to-manifests=${REMOVABLE_MEDIA_PATH}/certified_operators_manifests \
      ${CERT_OP_INDEX} replaceme

    sed -i 's|=replaceme/|=file://|g' ${REMOVABLE_MEDIA_PATH}/certified_operators_manifests/mapping.txt

    ${OC} image mirror \
      --filter-by-os=.* \
      --keep-manifest-list=true \
      --max-per-registry=6 \
      --max-registry=4 \
      --registry-config=${LOCAL_SECRET_JSON} \
      --dir="${REMOVABLE_MEDIA_PATH}/mirror" \
      --filename=${REMOVABLE_MEDIA_PATH}/certified_operators_manifests/mapping.txt

  fi

  if [ "${COMM_OP}" = true ]
  then
    ${OC} image mirror \
      --dir=${REMOVABLE_MEDIA_PATH}/mirror \
      --registry-config=${LOCAL_SECRET_JSON} \
      --keep-manifest-list=true \
      --filter-by-os=.* \
      registry.redhat.io/redhat/community-operator-index:v${OCP_RELEASE::3} \
      file://redhat/community-operator-index:v${OCP_RELEASE::3}

    mkdir -p "${REMOVABLE_MEDIA_PATH}/community_operators_manifests"

    ${OC} adm catalog mirror --manifests-only \
      --max-per-registry=${THREADS} \
      --registry-config ${LOCAL_SECRET_JSON} \
      --to-manifests=${REMOVABLE_MEDIA_PATH}/community_operators_manifests \
      ${COMM_OP_INDEX} replaceme

    sed -i 's|=replaceme/|=file://|g' ${REMOVABLE_MEDIA_PATH}/community_operators_manifests/mapping.txt

    ${OC} image mirror \
      --filter-by-os=.* \
      --keep-manifest-list=true \
      --max-per-registry=6 \
      --max-registry=4 \
      --registry-config=${LOCAL_SECRET_JSON} \
      --dir="${REMOVABLE_MEDIA_PATH}/mirror" \
      --filename=${REMOVABLE_MEDIA_PATH}/community_operators_manifests/mapping.txt
  fi

#  tar -cf "ocp-${OCP_RELEASE}-${ARCHITECTURE}-packaged.tar" "${REMOVABLE_MEDIA_PATH}"
fi

if [ "${UPLOAD}" = true ]
then

  # Push the OCP release images into the remote registry
  ${OC} image mirror -a ${LOCAL_SECRET_JSON} \
    --insecure=${LOCAL_REG_INSEC} \
    --from-dir=${REMOVABLE_MEDIA_PATH}/mirror \
    "file://openshift/release:${OCP_RELEASE}*" \
    ${REMOTE_REG}/${LOCAL_REPO}

#oc image mirror -a ${LOCAL_SECRET_JSON} --from-dir=${REMOVABLE_MEDIA_PATH}/mirror "file://openshift/release:${OCP_RELEASE}*" ${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}

  # Push the redhat-operators catalog image into the remote registry
#  ${OC} image mirror -a ${LOCAL_SECRET_JSON} \
#    --insecure=${LOCAL_REG_INSEC} \
#    --from-dir=${REMOVABLE_MEDIA_PATH}/mirror \
#    file://olm/redhat-operators:${OCP_RELEASE} \
#    ${REMOTE_REG}/olm/redhat-operators:${OCP_RELEASE}

  # Push the redhat-operators images into the remote registry
#  cat "${REMOVABLE_MEDIA_PATH}/operator_manifests/mapping.txt" \
#    | sed "s|=replaceme|=${REMOTE_REG}|g" \
#    | sed "s|=file://|=${REMOTE_REG}|g" \
#    | xargs -n 1 -P ${THREADS} ${OC} image mirror --registry-config=${LOCAL_SECRET_JSON} --dir="${REMOVABLE_MEDIA_PATH}/mirror" '{}'

fi

exit 0
