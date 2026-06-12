#!/bin/bash

REGISTRY="myregistry.com:8443"
ARCHITECTURE="x86_64"
OCP_RELEASE_VERSION=""  # Can get this from the cluster with oc version command?

NAMESPACE=openshift-update-service

NAME=service

# Need to set this for private registry based on oc-mirror
RELEASE_IMAGES=$(oc adm release info -o 'jsonpath={.digest}{"\n"}' ${REGISTRY}/openshift-release-dev/ocp-release:${OCP_RELEASE_VERSION}-${ARCHITECTURE})

#RELEASE_IMAGES=registry.example.com/ocp4/openshift4-release-images

# Need to set this for private registry based on oc-mirror
GRAPH_DATA_IMAGE="${REGISTRY}/openshift/graph-data:latest"
#GRAPH_DATA_IMAGE=registry.example.com/openshift/graph-data:latest

oc -n "${NAMESPACE}" create -f - <<EOF
apiVersion: updateservice.operator.openshift.io/v1
kind: UpdateService
metadata:
  name: ${NAME}
spec:
  replicas: 2
  releases: ${RELEASE_IMAGES}
  graphDataImage: ${GRAPH_DATA_IMAGE}
EOF

while sleep 1; do POLICY_ENGINE_GRAPH_URI="$(oc -n "${NAMESPACE}" get -o jsonpath='{.status.policyEngineURI}/api/upgrades_info/v1/graph{"\n"}' updateservice "${NAME}")"; SCHEME="${POLICY_ENGINE_GRAPH_URI%%:*}"; if test "${SCHEME}" = http -o "${SCHEME}" = https; then break; fi; done

while sleep 10; do HTTP_CODE="$(curl --header Accept:application/json --output /dev/stderr --write-out "%{http_code}" "${POLICY_ENGINE_GRAPH_URI}?channel=stable-4.6")"; if test "${HTTP_CODE}" -eq 200; then break; fi; echo "${HTTP_CODE}"; done


