#!/bin/bash

# Script to pull available operators and integrate their manifests
# into a disconnected operator hub

curl https://quay.io/cnr/api/v1/packages?namespace=redhat-operators > packages.txt
curl https://quay.io/cnr/api/v1/packages?namespace=community-operators >> packages.txt
curl https://quay.io/cnr/api/v1/packages?namespace=certified-operators >> packages.txt


curl https://quay.io/cnr/api/v1/packages/<namespace>/<operator_name>/<release>
