#!/bin/bash -xe

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  
# Source the environment file with the default settings
source "${SCRIPT_DIR}/../env.sh"

${OC} image mirror --force --filter-by-os=.* --keep-manifest-list=true \
    --registry-config ${LOCAL_SECRET_JSON} \
    --insecure=true \
    'quay.io/kubernetes_incubator/node-feature-discovery:v0.5.0' \
    "${REMOTE_REG}/kubernetes_incubator/node-feature-discovery:v0.5.0"


${OC} image mirror --force --filter-by-os=.* --keep-manifest-list=true \
    --registry-config ${LOCAL_SECRET_JSON} \
    --insecure=true \
    'docker.io/nvidia/gpu-operator:1.1.7' \
    "${REMOTE_REG}/nvidia/gpu-operator:1.1.7"

# This is the one that we are replacing
#${OC} image mirror --force --filter-by-os=.* --keep-manifest-list=true \
#    --registry-config ${LOCAL_SECRET_JSON} \
#    --insecure=true \
#    'docker.io/nvidia/driver:440.64.00' \
#    "${REMOTE_REG}/nvidia/driver"

${OC} image mirror --force --filter-by-os=.* --keep-manifest-list=true \
    --registry-config ${LOCAL_SECRET_JSON} \
    --insecure=true \
    'quay.io/danclark/nvidia-driver:450.51.06-1.0.0-custom-rhcos-4.18.0-147.8.1.el8_1.x86_64-4.3.8' \
    "${REMOTE_REG}/nvidia/driver450.51.06-1.0.0-custom-rhcos-4.18.0-147.8.1.el8_1.x86_64-4.3.8"

${OC} image mirror --force --filter-by-os=.* --keep-manifest-list=true \
    --registry-config ${LOCAL_SECRET_JSON} \
    --insecure=true \
    'quay.io/danclark/nvidia-driver:450.51.06-1.0.0-custom-rhcos-4.18.0-147.8.1.el8_1.x86_64-4.3.8' \
    "${REMOTE_REG}/nvidia/driver450.51.06-1.0.0-custom-rhcos-4.18.0-147.8.1.el8_1.x86_64-4.3.8-rhcos4.5"

${OC} image mirror --force --filter-by-os=.* --keep-manifest-list=true \
    --registry-config ${LOCAL_SECRET_JSON} \
    --insecure=true \
    'quay.io/danclark/nvidia-driver:450.51.06-1.0.0-custom-rhcos-4.18.0-193.13.2.el8_2.x86_64-4.5.2' \
    "${REMOTE_REG}/nvidia/driver:450.51.06-1.0.0-custom-rhcos-4.18.0-193.13.2.el8_2.x86_64-4.5.2"

${OC} image mirror --force --filter-by-os=.* --keep-manifest-list=true \
    --registry-config ${LOCAL_SECRET_JSON} \
    --insecure=true \
    'quay.io/danclark/nvidia-driver:450.51.06-1.0.0-custom-rhcos-4.18.0-193.13.2.el8_2.x86_64-4.5.2' \
    "${REMOTE_REG}/nvidia/driver:450.51.06-1.0.0-custom-rhcos-4.18.0-193.13.2.el8_2.x86_64-4.5.2-rhcos4.5"

${OC} image mirror --force --filter-by-os=.* --keep-manifest-list=true \
    --registry-config ${LOCAL_SECRET_JSON} \
    --insecure=true \
    'docker.io/nvidia/container-toolkit:1.0.2' \
    "${REMOTE_REG}/nvidia/container-toolkit:1.0.2"

${OC} image mirror --force --filter-by-os=.* --keep-manifest-list=true \
    --registry-config ${LOCAL_SECRET_JSON} \
    --insecure=true \
    'docker.io/nvidia/k8s-device-plugin:1.0.0-beta6' \
    "${REMOTE_REG}/nvidia/k8s-device-plugin:1.0.0-beta6"

${OC} image mirror --force --filter-by-os=.* --keep-manifest-list=true \
    --registry-config ${LOCAL_SECRET_JSON} \
    --insecure=true \
    'docker.io/nvidia/dcgm-exporter:1.7.2-2.0.0-rc.9-ubuntu18.04' \
    "${REMOTE_REG}/nvidia/dcgm-exporter:1.7.2-2.0.0-rc.9-ubuntu18.04"

