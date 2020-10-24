#!/bin/bash

oc image mirror --force --filter-by-os=.* --keep-manifest-list=true \
   --registry-config ${LOCAL_SECRET_JSON} \
   --insecure=true 'quay.io/cincinnati/cincinnati-operator:latest' \
   "${REMOTE_REG}/cincinnati/cincinnati-operator:latest"

oc image mirror --force --filter-by-os=.* --keep-manifest-list=true \
   --registry-config ${LOCAL_SECRET_JSON} \
   --insecure=true 'quay.io/app-sre/cincinnati:2873c6b' \
   "${REMOTE_REG}/app-sre/cincinnati:2873c6b"
