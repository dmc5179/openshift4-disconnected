#!/bin/bash -xe

# Configure the replica set of the ingress operator

${OC} patch -n openshift-ingress-operator ingresscontroller/default --patch "{\"spec\":{\"replicas\": $1}}" --type=merge
