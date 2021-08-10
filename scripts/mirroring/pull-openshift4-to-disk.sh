#!/bin/bash -e

export OCP_RELEASE="4.6.9"
export OCP_ARCH="x86_64"

# Directory where OCP images are written to or read from
# When mirroring to disk
export OCP_MEDIA_PATH="/opt/ocp-${OCP_RELEASE}"

# This needs to be a pull secret that combines the pull secret from Red Hat
# to pull all the images down and a pull secret from your local registry so we
# can push to it
export LOCAL_SECRET_JSON="${HOME}/pull-secret.json"

######
# Unlikely that these need to be changed
export RELEASE_NAME="ocp-release"
export UPSTREAM_REPO='openshift-release-dev'
######

set -x

#############################################################

mkdir -p "${OCP_MEDIA_PATH}/mirror"

echo "Mirroring cluster images"
oc adm release mirror -a ${LOCAL_SECRET_JSON} \
  --from=quay.io/${UPSTREAM_REPO}/${RELEASE_NAME}:${OCP_RELEASE}-${OCP_ARCH} \
  --to file://openshift/release \
  --to-dir=${OCP_MEDIA_PATH}/mirror

exit 0
