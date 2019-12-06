#!/bin/bash

BUCKET='ocp-4.2.0'

mkdir /tmp/ocp
pushd /tmp/ocp

aws s3 cp "s3://ocp-4.2.0/clients/openshift-client-linux-4.2.4.tar.gz" .

tar -xzf openshift-client-linux-4.2.4.tar.gz
sudo mv kubectl /usr/local/bin/
sudo mv oc /usr/local/bin
sudo chown root.root /usr/local/bin/kubectl /usr/local/bin/oc
sudo chmod +x /usr/local/bin/kubectl /usr/local/bin/oc

popd
rm -rf /tmp/ocp
mkdir ocp
pushd /tmp/ocp

aws s3 cp "s3://ocp-4.2.0/clients/openshift-install-linux-4.2.4.tar.gz" .

tar -xzf openshift-install-linux-4.2.4.tar.gz
sudo mv openshift-install /usr/local/bin/
sudo chown root.root /usr/local/bin/openshift-install
sudo chmod +x /usr/local/bin/openshift-install

