#!/bin/bash -xe

REGISTRY="registry.example.com:5000"

${OC} patch configs.samples.operator.openshift.io cluster --type merge \
  --patch "{\"spec\":{\"samplesRegistry\": \"${REGISTRY}\", \"managementState\": \"Managed\"}}"
