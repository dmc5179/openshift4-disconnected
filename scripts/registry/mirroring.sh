#!/bin/bash

export OCP_RELEASE="4.3.21-x86_64"
export LOCAL_REG='localhost:5000'
export LOCAL_REPO='ocp4/openshift4'
export LOCAL_REG_INSEC='true'
export UPSTREAM_REPO='openshift-release-dev'

# This needs to be a pull secret that combines the pull secret from Red Hat
# to pull all the images down and a pull secret from your local registry so we
# can push to it
export LOCAL_SECRET_JSON="${HOME}/pull-secret.json"
export RELEASE_NAME="ocp-release"

/usr/local/bin/oc adm release mirror -a ${LOCAL_SECRET_JSON} \
--insecure=${LOCAL_REG_INSEC} \
--from=quay.io/${UPSTREAM_REPO}/${RELEASE_NAME}:${OCP_RELEASE} \
--to-release-image=${LOCAL_REG}/${LOCAL_REPO}:${OCP_RELEASE} \
--to=${LOCAL_REG}/${LOCAL_REPO}


# Example to use a dir instead of a registry
# https://github.com/openshift/oc/pull/126
#oc adm release mirror quay.io/openshift-release-dev/ocp-release:4.3.1-x86_64 --to-dir=/tmp/release
#oc image mirror --from-dir=/tmp/release file://openshift/release myregistry.com/my/repository

