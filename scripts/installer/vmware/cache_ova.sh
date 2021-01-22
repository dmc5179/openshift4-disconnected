#!/bin/bash

OVA=$(curl https://raw.githubusercontent.com/openshift/installer/release-4.6/data/data/rhcos.json | jq -r '.images.vmware.path' rhcos.json)
SHA=$(curl https://raw.githubusercontent.com/openshift/installer/release-4.6/data/data/rhcos.json | jq -r '.images.vmware.sha256' rhcos.json)

curl -O "https://releases-art-rhcos.svc.ci.openshift.org/art/storage/releases/rhcos-4.6/46.82.202011260640-0/x86_64/${OVA}?sha256=${SHA}"
