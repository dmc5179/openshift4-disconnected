#!/bin/bash


# Cleanup pods stuck in the Error state

for project in $(oc get pods --all-namespaces| grep Error| awk '{print $1}' | uniq)
do

  echo "Cleaning up pods in project: $project"

  oc delete po $(oc get pods -n $project | grep Error | awk '{print $1}') -n $project --grace-period=0 --force

done
