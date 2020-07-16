#!/bin/bash

# Set OpenShift internal registry to use the empty dir for storage
# Typically done in UPI installs when no default storage class is available
# Configure the registry to use storage when available

oc patch configs.imageregistry.operator.openshift.io cluster --type merge --patch '{"spec":{"storage":{"emptyDir":{}}}}'
