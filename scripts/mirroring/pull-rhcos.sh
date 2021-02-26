#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Source the environment file with the default settings
source "${SCRIPT_DIR}/../env.sh"

set -x

#############################################################

mkdir -p "${OCP_MEDIA_PATH}/mirror"
mkdir -p "${RHCOS_MEDIA_PATH}"

pushd  "${RHCOS_MEDIA_PATH}"

# Coreos installer binary
wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/coreos-installer/latest/coreos-installer

wget https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/${OCP_RELEASE::3}/${RHCOS_VER}/rhcos-${RHCOS_VER}-x86_64-live-initramfs.x86_64.img

wget https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/${OCP_RELEASE::3}/${RHCOS_VER}/rhcos-${RHCOS_VER}-x86_64-live-kernel-x86_64

wget https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/${OCP_RELEASE::3}/${RHCOS_VER}/rhcos-${RHCOS_VER}-x86_64-live-rootfs.x86_64.img

wget https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/${OCP_RELEASE::3}/${RHCOS_VER}/rhcos-${RHCOS_VER}-x86_64-live.x86_64.iso

wget https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/${OCP_RELEASE::3}/${RHCOS_VER}/rhcos-${RHCOS_VER}-x86_64-aws.x86_64.vmdk.gz


popd

exit 0
