#!/bin/bash

export OCP_RELEASE="4.2.0-0.nightly-2019-08-29-062233"
export LOCAL_REG='registry.ocp4.example.com:5000'
export LOCAL_REPO='ocp4/openshift4'
export UPSTREAM_REPO='openshift-release-dev'

# This needs to be a pull secret that combines the pull secret from Red Hat
# to pull all the images down and a pull secret from your local registry so we
# can push to it
export LOCAL_SECRET_JSON="${HOME}/pull-secret-2.json"
export RELEASE_NAME="ocp-release-nightly"



oc adm release mirror -a ${LOCAL_SECRET_JSON} \
--from=quay.io/${UPSTREAM_REPO}/${RELEASE_NAME}:${OCP_RELEASE} \
--to-release-image=${LOCAL_REG}/${LOCAL_REPO}:${OCP_RELEASE} \
--to=${LOCAL_REG}/${LOCAL_REPO}

