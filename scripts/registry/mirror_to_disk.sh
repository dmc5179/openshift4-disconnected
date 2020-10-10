#!/bin/bash -xe

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  
# Source the environment file with the default settings
source "${SCRIPT_DIR}/../env.sh"

# Example to use a dir instead of a registry
# https://github.com/openshift/oc/pull/126
#oc adm release mirror quay.io/openshift-release-dev/ocp-release:4.3.1-x86_64 --to-dir=/tmp/release
#oc image mirror --from-dir=/tmp/release file://openshift/release myregistry.com/my/repository

mkdir -p "${REMOVABLE_MEDIA_PATH}/mirror"

oc adm release mirror -a ${LOCAL_SECRET_JSON} \
--insecure=${LOCAL_REG_INSEC} \
--from=quay.io/${UPSTREAM_REPO}/${RELEASE_NAME}:${OCP_RELEASE}-${ARCHITECTURE} \
--to-dir=${REMOVABLE_MEDIA_PATH}/mirror

