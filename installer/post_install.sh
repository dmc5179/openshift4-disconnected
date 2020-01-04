#!/bin/bash

# Commands to cleanup the cluster post install.
# By post install I mean the nodes are all up but the cluster
# is still trying to sort itself out

# Configure the registry to use an empty dir
oc patch configs.imageregistry.operator.openshift.io cluster --type merge --patch '{"spec":{"storage":{"emptyDir":{}}}}'

# Turn off the built in Operator Hub. We'll fix it later
oc patch OperatorHub cluster --type json -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'

# Follow this guide to disable telemetry
# Note: this just removes the auth token which isn't really disabling anything. I plan to file a bug on this
# https://docs.openshift.com/container-platform/4.2/support/remote_health_monitoring/opting-out-of-remote-health-reporting.html#opting-out-remote-health-reporting_opting-out-remote-health-reporting

# Reduce Ingress Operators. This can be done to lower the resource usage of the cluster or troubleshoot ingress issues.
# Don't start out by doing this.
# oc patch -n openshift-ingress-operator ingresscontroller/default --patch '{"spec":{"replicas": 1}}' --type=merge

