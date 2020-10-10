#!/bin/bash -xe

# Disable the OpenShift integrated OperatorHub.
# Typically done for disconnected/air-gap installs until the disconnected
# version of OperatorHub is installed

${OC} patch OperatorHub cluster --type json -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'
