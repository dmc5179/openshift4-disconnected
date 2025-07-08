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
  oc get -A pods | grep -v Completed | grep -v '1/1' | grep -v '2/2' | grep -v '3/3' | grep -v '4/4' | grep -v '5/5' | grep -v '6/6' | grep -v '7/7' | grep -v '8/8'
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


