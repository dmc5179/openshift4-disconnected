#!/bin/bash -xe

${OC} image mirror \
  --from-dir=${OCP_MEDIA_PATH}/mirror \
  "file://openshift/release:${OCP_RELEASE}*" \
  ${LOCAL_REG}/${LOCAL_REPO}

exit 0
