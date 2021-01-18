#!/bin/bash

# Cleanup pods stuck in Terminating state

# Don't use this right after deleting a pods. This is meant to force kill a pods which should only be done
# if the pods is really stuck

for project in $(oc get pods --all-namespaces| grep Terminating| awk '{print $1}' | uniq)
do

  echo "Cleaning up pods in project: $project"

  oc delete po $(oc get pods -n $project | grep Terminating| awk '{print $1}') -n $project --grace-period=0 --force

done
