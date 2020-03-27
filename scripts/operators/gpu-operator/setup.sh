#!/bin/bash -xe

OPERATOR=gpu-operator-1.0.0.tgz
DIGEST=$(sha256sum ${OPERATOR})

# Comes from https://nvidia.github.io/gpu-operator/index.yaml
INDEX=index.yaml

HTML_LOC=gpu-operator

HELM_HOST=

# Copy the helm index and chart in place
sudo mkdir -p "/var/www/html/${HTML_LOC}"
sudo cp ${INDEX} "/var/www/html/${HTML_LOC}/"
sudo cp ${OPERATOR} "/var/www/html/${HTML_LOC}/"
sudo chmod 644 "/var/www/html/${HTML_LOC}/*"
sudo restorecon -Rv "/var/www/html"

# The helm chart has been updated and repackaged so replace the digest
sudo sed -i "s|digest:.*|digest: ${DIGEST}|" "/var/www/html/${HTML_LOC}/${INDEX}"


helm install --devel http://${HELM_HOST}/gpu-operator/gpu-operator-1.0.0.tgz --set platform.openshift=true,operator.defaultRuntime=crio,nfd.enabled=false --wait --generate-name


