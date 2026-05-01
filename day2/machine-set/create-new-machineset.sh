#!/bin/bash

export EXISTING=""                     # Name of an existing machineset to clone
export INITIAL_REPLICAS=1              # Initial number of replicas for the new machineset
export NEW_NAME=""                     # Name of the new machineset, follow pattern of existing one
export AWS_INSTANCE_TYPE="m5.2xlarge"  # AWS EC2 instance type for the new machineset
export SPOT=1                          # If the machineset should use spot instances


###############################
TMP="${EXISTING}-tmp.json"
NEW="${NEW_NAME}.json"
##############################

# Export an existing MachineSet
oc get -o json -n openshift-machine-api machineset "${EXISTING}" > "${NEW}"

# Remove generated data from existing MachineSet
jq 'del(.metadata.generation)' "${NEW}" > "${TMP}" && mv "${TMP}" "${NEW}"
jq 'del(.metadata.creationTimestamp)' "${NEW}" > "${TMP}" && mv "${TMP}" "${NEW}"
jq 'del(.metadata.resourceVersion)' "${NEW}" > "${TMP}" && mv "${TMP}" "${NEW}"
jq 'del(.metadata.uid)' "${NEW}" > "${TMP}" && mv "${TMP}" "${NEW}"
jq 'del(.metadata.annotations)' "${NEW}" > "${TMP}" && mv "${TMP}" "${NEW}"
jq 'del(.status)' "${NEW}" > "${TMP}" && mv "${TMP}" "${NEW}"

# Set replicas
jq --argjson val $INITIAL_REPLICAS '.spec.replicas = $val' "${NEW}" > "${TMP}" && mv "${TMP}" "${NEW}"

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

echo "New MachineSet yaml located here: ${NEW}"

echo "To create the new machineset, run the following command: oc create -f ${NEW}"
