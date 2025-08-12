#!/bin/bash

PULL_SECRET=/home/user/pull-secret
OCP_VERSION=4.19.7
ARCH=x86_64
PRIVATE_REGISTRY="myregistry.com:8443"

# Command to extract from public quay registry
#oc adm release extract --registry-config=${PULL_SECRET} --tools quay.io/openshift-release-dev/ocp-release:${OCP_VERSION}-${ARCH}


# oc-mirror by default will put the image above into openshift/release-images
# so the command looks like

oc adm release extract --registry-config=${PULL_SECRET} --tools "${PRIVATE_REGISTRY}/openshift/release-images:${OCP_VERSION}-${ARCH}"
