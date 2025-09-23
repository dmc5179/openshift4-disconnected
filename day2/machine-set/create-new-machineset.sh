#!/bin/bash

EXISTING="ecs-2tzpd-worker-us-east-2a"
#NEW="${EXISTING}.json"
TMP="${EXISTING}-tmp.json"
INITIAL_REPLICAS=1
NEW_NAME="ecs-2tzpd-worker-spot-us-east-2a"
NEW="${NEW_NAME}.json"
AWS_INSTANCE_TYPE="m5.2xlarge"
SPOT=1

# Copy file
#cp "${EXISTING}" "${NEW}"

# Export an existing MachineSet
oc get -o json machineset "${EXISTING}" > "${NEW}"

# Remove generated data from existing MachineSet
jq 'del(.metadata.generation)' "${NEW}" > "${TMP}" && mv "${TMP}" "${NEW}"
jq 'del(.metadata.creationTimestamp)' "${NEW}" > "${TMP}" && mv "${TMP}" "${NEW}"
jq 'del(.metadata.resourceVersion)' "${NEW}" > "${TMP}" && mv "${TMP}" "${NEW}"
jq 'del(.metadata.uid)' "${NEW}" > "${TMP}" && mv "${TMP}" "${NEW}"
jq 'del(.metadata.annotations)' "${NEW}" > "${TMP}" && mv "${TMP}" "${NEW}"
jq 'del(.status)' "${NEW}" > "${TMP}" && mv "${TMP}" "${NEW}"

# Set replicas
jq --arg replicas "${INITIAL_REPLICAS}" '.spec.replicas = \"$replicas\"' "${NEW}" > "${TMP}" && mv "${TMP}" "${NEW}"

# Set instance Type
jq --arg instance "${AWS_INSTANCE_TYPE}" '.spec.template.spec.providerSpec.value.instanceType = $instance' "${NEW}" > "${TMP}" && mv "${TMP}" "${NEW}"

jq --arg name "${NEW_NAME}" '.metadata.name = $name' "${NEW}" > "${TMP}" && mv "${TMP}" "${NEW}"

jq --arg name "${NEW_NAME}" '.spec.selector.matchLabels."machine.openshift.io/cluster-api-machineset" = $name' "${NEW}" > "${TMP}" && mv "${TMP}" "${NEW}"

jq --arg name "${NEW_NAME}" '.spec.template.metadata.labels."machine.openshift.io/cluster-api-machineset" = $name' "${NEW}" > "${TMP}" && mv "${TMP}" "${NEW}"

if [ ${SPOT} != 0 ]
then
 echo "prepare spot instance"
 jq '.' "${NEW}" | jq '.spec.template.spec.providerSpec.value.spotMarketOptions = {}' > "${TMP}" && mv "${TMP}" "${NEW}"
fi
