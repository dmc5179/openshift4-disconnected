#!/bin/bash -e

export OCP_RELEASE="4.6.9"

# Directory where OCP images are written to or read from
# When mirroring to disk
export OCP_MEDIA_PATH="/opt/ocp-${OCP_RELEASE}"

# This needs to be a pull secret that combines the pull secret from Red Hat
# to pull all the images down and a pull secret from your local registry so we
# can push to it
export LOCAL_SECRET_JSON="${HOME}/pull-secret.json"

# Registry to push the OpenShift 4 container images to 
export LOCAL_REG='localhost:5000'

# Repository in the registry where the OpenShift 4 images will be pushed
export LOCAL_REPO='ocp4/openshift4'

set -x

oc image mirror \
  --registry-config=${LOCAL_SECRET_JSON} \
  --from-dir=${OCP_MEDIA_PATH}/mirror \
  "file://openshift/release:${OCP_RELEASE}*" \
  ${LOCAL_REG}/${LOCAL_REPO}

exit 0
