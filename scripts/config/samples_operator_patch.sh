#!/bin/bash -xe

REGISTRY="registry.example.com:5000"

oc patch configs.samples.operator.openshift.io cluster --type merge \
  --patch "{\"spec\":{\"samplesRegistry\": \"${REGISTRY}\", \"managementState\": \"Managed\"}}"
