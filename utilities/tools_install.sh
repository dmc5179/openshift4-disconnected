#!/bin/bash

# Download the openshift client and install tools
# OCP locks container images, ignition files, and install tools like openshift-install. They all have to match versions
# Which is why the location of the tools install is configurable so you can install more than one if needed
# The images are digest based and the install client creates ignition files to pull digests

OCP_VERSION=4.2.12
TOOLS_DIR=/usr/local/bin

mkdir /tmp/ocp
pushd /tmp/ocp

wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OCP_VERSION}/openshift-client-linux-${OCP_VERSION}.tar.gz

tar -xzf openshift-client-linux-${OCP_VERSION}.tar.gz
sudo mv kubectl ${TOOLS_DIR}/
sudo mv oc ${TOOLS_DIR}/
sudo chown root.root ${TOOLS_DIR}/kubectl ${TOOLS_DIR}/oc
sudo chmod +x ${TOOLS_DIR}/kubectl ${TOOLS_DIR}/oc

popd
rm -rf /tmp/ocp
mkdir ocp
pushd /tmp/ocp

wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OCP_VERSION}/openshift-install-linux-${OCP_VERSION}.tar.gz

tar -xzf openshift-install-linux-${OCP_VERSION}.tar.gz
sudo mv openshift-install ${TOOLS_DIR}/
sudo chown root.root ${TOOLS_DIR}/openshift-install
sudo chmod +x ${TOOLS_DIR}/openshift-install

popd
rm -rf /tmp/ocp

mkdir /tmp/filetranspiler
pushd /tmp/filetranspiler

wget https://github.com/ashcrow/filetranspiler/archive/1.1.0.tar.gz
tar -xzf 1.1.0.tar.gz
sudo mv filetranspiler-1.1.0/filetranspile ${TOOLS_DIR}/
sudo chown root.root ${TOOLS_DIR}/filetranspile
sudo chmod +x ${TOOLS_DIR}/filetranspile

popd
rm -rf /tmp/filetranspiler

exit 0
