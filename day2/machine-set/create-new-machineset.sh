#!/bin/bash -ex

EXISTING="ecs-2tzpd-worker-us-east-2a"
#NEW="${EXISTING}.json"
TMP="${EXISTING}-tmp.json"
INITIAL_REPLICAS=0
NEW_NAME="ecs-2tzpd-worker-gpu-us-east-2a"
NEW="${NEW_NAME}.json"
AWS_INSTANCE_TYPE="g4dn.4xlarge"

# Copy file
#cp "${EXISTING}" "${NEW}"

oc get -o json machineset "${EXISTING}" > "${NEW}"

jq 'del(.metadata.generation)' "${NEW}" > "${TMP}" && mv "${TMP}" "${NEW}"
jq 'del(.metadata.creationTimestamp)' "${NEW}" > "${TMP}" && mv "${TMP}" "${NEW}"
jq 'del(.metadata.resourceVersion)' "${NEW}" > "${TMP}" && mv "${TMP}" "${NEW}"
jq 'del(.metadata.uid)' "${NEW}" > "${TMP}" && mv "${TMP}" "${NEW}"
jq 'del(.metadata.annotations)' "${NEW}" > "${TMP}" && mv "${TMP}" "${NEW}"

# Set replicas
jq --arg replicas "${INITIAL_REPLICAS}" ".spec.replicas = $replicas" "${NEW}" > "${TMP}" && mv "${TMP}" "${NEW}"

# Set instance Type
jq --arg instance "${AWS_INSTANCE_TYPE}" '.spec.template.spec.providerSpec.value.instanceType = $instance' "${NEW}" > "${TMP}" && mv "${TMP}" "${NEW}"


#### These names must be updated
jq --arg name "${NEW_NAME}" '.metadata.name = $name' "${NEW}" > "${TMP}" && mv "${TMP}" "${NEW}"

jq --arg name "${NEW_NAME}" '.spec.selector.matchLabels."machine.openshift.io/cluster-api-machineset" = $name' "${NEW}" > "${TMP}" && mv "${TMP}" "${NEW}"

jq --arg name "${NEW_NAME}" '.spec.template.metadata.labels."machine.openshift.io/cluster-api-machineset" = $name' "${NEW}" > "${TMP}" && mv "${TMP}" "${NEW}"
