#!/bin/bash -xe
export OC="/usr/local/bin/oc"
export OCP_RELEASE="4.6.9"
export ARCHITECTURE="x86_64"
export LOCAL_REG='localhost:5000'
export LOCAL_REPO='ocp4/openshift4'
export LOCAL_REG_INSEC='true'
export UPSTREAM_REPO='openshift-release-dev'
export OCP_ARCH="x86_64"
# Directory where OCP images are written to or read from
# When mirroring to disk
export REMOVABLE_MEDIA_PATH="/opt/data/openshift/diff"

# Registry where cluster images live for the disconnected cluster
export REMOTE_REG="1234567890.dkr.ecr.us-east-1.amazonaws.com"

# This needs to be a pull secret that combines the pull secret from Red Hat
# to pull all the images down and a pull secret from your local registry so we
# can push to it
export LOCAL_SECRET_JSON="${HOME}/pull-secret.txt"
export RELEASE_NAME="ocp-release"





# Somehow to-mirror=true means don't mirror just show image list
# to-dir is required but nothing is put there
echo "Mirroring cluster images"
${OC} adm release mirror -a ${LOCAL_SECRET_JSON} \
    --from=quay.io/${UPSTREAM_REPO}/${RELEASE_NAME}:${OCP_RELEASE}-${ARCHITECTURE} \
    --to-mirror=true \
    --to-dir=. > "${REMOVABLE_MEDIA_PATH}/ocp-${OCP_RELEASE}-${OCP_ARCH}.txt"
