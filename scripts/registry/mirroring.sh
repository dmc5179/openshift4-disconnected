#!/bin/bash

# Source the environment file with the default settings
. ./env.sh

/usr/local/bin/oc adm release mirror -a ${LOCAL_SECRET_JSON} \
--insecure=${LOCAL_REG_INSEC} \
--from=quay.io/${UPSTREAM_REPO}/${RELEASE_NAME}:${OCP_RELEASE} \
--to-release-image=${LOCAL_REG}/${LOCAL_REPO}:${OCP_RELEASE} \
--to=${LOCAL_REG}/${LOCAL_REPO}


# Example to use a dir instead of a registry
# https://github.com/openshift/oc/pull/126
#oc adm release mirror quay.io/openshift-release-dev/ocp-release:4.3.1-x86_64 --to-dir=/tmp/release
#oc image mirror --from-dir=/tmp/release file://openshift/release myregistry.com/my/repository

