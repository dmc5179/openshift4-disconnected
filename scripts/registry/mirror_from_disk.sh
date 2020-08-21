#!/bin/bash -xe

# Source the environment file with the default settings
. ./env.sh

oc image mirror -a ${LOCAL_SECRET_JSON} \
--insecure=${LOCAL_REG_INSEC} \
--from-dir=${REMOVABLE_MEDIA_PATH}/mirror \
'file://openshift/release:${OCP_RELEASE}*' \
${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}
