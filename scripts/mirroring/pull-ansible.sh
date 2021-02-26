#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Source the environment file with the default settings
source "${SCRIPT_DIR}/../env.sh"

set -x

#############################################################

mkdir -p "${OCP_MEDIA_PATH}/ansible/ansible_collections"

for c in freeipa.ansible_freeipa containers.podman community.general
do

  ansible-galaxy collection install --force-with-deps -f -p "${OCP_MEDIA_PATH}/ansible/ansible_collections/" $c

done

exit 0
