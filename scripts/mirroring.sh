#!/bin/bash -xe
export OCP_RELEASE="4.5.4"
export ARCHITECTURE="x86_64"
export LOCAL_REG='localhost:5000'
export LOCAL_REPO='ocp4/openshift4'
export LOCAL_REG_INSEC='true'
export UPSTREAM_REPO='openshift-release-dev'
export OCP_ARCH="x86_64"
# Directory where OCP images are written to or read from
# When mirroring to disk
export REMOVABLE_MEDIA_PATH="/home/danclark/packed/ocp-${OCP_RELEASE}"

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

export RH_OP_REPO="${LOCAL_REG}/olm/redhat-operators:${OCP_RELEASE}"
export CERT_OP_REPO="${LOCAL_REG}/olm/certified-operators:${OCP_RELEASE}"
export COMM_OP_REPO="${LOCAL_REG}/olm/community-operators:${OCP_RELEASE}"

export OPERATOR_REGISTRY='quay.io/operator-framework/operator-registry-server:v1.13.6'

# This is either the directory backing the local podman registry, i.e; /opt/registry/data
# Or this is the directory where the images will be mirrored to/from if using --to-dir
export DATA_DIR="/opt/registry/data/docker/"

export THREADS=1

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
  mkdir -p "${REMOVABLE_MEDIA_PATH}/operator_manifests"

  # Looks like this is working
  # Mirror the cluster images to disk
  echo "Mirroring cluster images"
  oc adm release mirror -a ${LOCAL_SECRET_JSON} \
    --insecure=${LOCAL_REG_INSEC} \
    --from=quay.io/${UPSTREAM_REPO}/${RELEASE_NAME}:${OCP_RELEASE}-${ARCHITECTURE} \
    --to file://openshift/release \
    --to-dir=${REMOVABLE_MEDIA_PATH}/mirror

  # Looks like this is working
  # Build the redhat-operators catalog source and mirror to disk
  echo "Building redhat-operators catalog image"
  oc adm catalog build --insecure \
    --appregistry-org redhat-operators \
    "--from=${OPERATOR_REGISTRY}" "--registry-config=${LOCAL_SECRET_JSON}" \
    --dir=${REMOVABLE_MEDIA_PATH}/mirror \
    --to=file://olm/redhat-operators:${OCP_RELEASE}

  # Grab the operator manifests
  oc adm catalog mirror --manifests-only \
    --registry-config "${LOCAL_SECRET_JSON}" --insecure=true \
    --to-manifests=${REMOVABLE_MEDIA_PATH}/operator_manifests \
    "quay.io/danclark/redhat-operators:v1" --dir=${REMOVABLE_MEDIA_PATH}/operators file://replaceme

# Mirror the images with multiple threads
# This sed command is weird because the images mirrored by tag already have file in them but not the digest based ones
  cat "${REMOVABLE_MEDIA_PATH}/operator_manifests/mapping.txt" | sed 's|=replaceme|=file://|g' | xargs -n 1 -P ${THREADS} oc image mirror --filter-by-os=.* --keep-manifest-list=true --registry-config=${LOCAL_SECRET_JSON} --dir="${REMOVABLE_MEDIA_PATH}/mirror" '{}'

  tar -cf "ocp-${OCP_RELEASE}-${ARCHITECTURE}-packaged.tar" "${REMOVABLE_MEDIA_PATH}"
fi

if [ "${UPLOAD}" = true ]
then

  # Push the OCP release images into the remote registry
  oc image mirror -a ${LOCAL_SECRET_JSON} \
    --insecure=${LOCAL_REG_INSEC} \
    --from-dir=${REMOVABLE_MEDIA_PATH}/mirror \
    file://openshift/release:${OCP_RELEASE}* \
    ${REMOTE_REG}/${LOCAL_REPOSITORY}

  # Push the redhat-operators catalog image into the remote registry
  oc image mirror -a ${LOCAL_SECRET_JSON} \
    --insecure=${LOCAL_REG_INSEC} \
    --from-dir=${REMOVABLE_MEDIA_PATH}/mirror \
    file://olm/redhat-operators:${OCP_RELEASE} \
    ${REMOTE_REG}/olm/redhat-operators:${OCP_RELEASE}

  # Push the redhat-operators images into the remote registry
  cat "${REMOVABLE_MEDIA_PATH}/operator_manifests/mapping.txt" \
    | sed "s|=replaceme|=${REMOTE_REG}|g" \
    | sed "s|=file://|=${REMOTE_REG}|g" \
    | xargs -n 1 -P ${THREADS} oc image mirror --registry-config=${LOCAL_SECRET_JSON} --dir="${REMOVABLE_MEDIA_PATH}/mirror" '{}'

fi

exit 0
