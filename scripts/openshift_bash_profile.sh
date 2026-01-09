#!/bin/bash

# Handy OpenShift CLI commands

function set_master_schedulable {
  oc patch schedulers.config.openshift.io cluster --type merge --patch "{\"spec\":{\"mastersSchedulable\":true}}"
}
export -f set_master_schedulable

function disable_operatorhub {
  oc patch OperatorHub cluster --type json -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'
}
export -f disable_operatorhub

function getbadpods {
  oc get pods --all-namespaces | awk '$4 != "Completed" && $3 !~ /^[0-9]+\/[0-9]+$/ {print $0}'
}
export -f getbadpods

function clearerrorpods {
  oc delete -A pod --field-selector=status.phase==Failed
}
export -f clearerrorpods

function clearcompletedpods {
  oc delete -A pod --field-selector=status.phase==Succeeded
}
export -f clearcompletedpods

function approvecsrs {
while true
do
  echo -n "Checking for CSRs: "
  date
  if [[ $(oc get -A csr | grep -i pending | wc -l) > 0 ]]
  then
    oc get -A csr | grep -i pending | awk '{print $1}' | xargs oc adm certificate approve
  fi
  sleep 10
done
}
export -f approvecsrs

function disable_telemetry {
  if [[ ! `which jq 2>/dev/null` ]]
  then
    echo "Please install jq using pip or yum"
    exit 1
  fi
  
  oc extract secret/pull-secret -n openshift-config --to=.
  jq 'del(.auths["cloud.openshift.com"])' .dockerconfigjson > .dockerconfigjson.tmp
  mv .dockerconfigjson.tmp .dockerconfigjson
  oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=.dockerconfigjson
  rm -f .dockerconfigjson
}
export -f disable_telemetry

# For those using the oc cli with multiple clusters and setting the oc context
# The below function will add the name of the cluster to your bash terminal prompt
function update_ps1() {
  KUBE_CONTEXT=$(yq '.current-context' ~/.kube/config | awk -F\/ '{print $2}' | awk -F\- '{print $2}')
  PS1="[${KUBE_CONTEXT}] \u@\h:\w \$ "
}
PROMPT_COMMAND=update_ps1
