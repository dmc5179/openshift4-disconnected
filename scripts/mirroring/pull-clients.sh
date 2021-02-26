#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Source the environment file with the default settings
source "${SCRIPT_DIR}/../env.sh"

set -x

#############################################################

mkdir -p "${OCP_MEDIA_PATH}/clients"

pushd  "${OCP_MEDIA_PATH}/clients"

wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/${OCP_RELEASE}/openshift-client-linux-${OCP_RELEASE}.tar.gz
wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/${OCP_RELEASE}/openshift-client-windows-${OCP_RELEASE}.zip
wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/${OCP_RELEASE}/openshift-install-linux-${OCP_RELEASE}.tar.gz
wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/${OCP_RELEASE}/opm-linux-${OCP_RELEASE}.tar.gz

wget https://github.com/ashcrow/filetranspiler/archive/master.zip

popd

exit 0
