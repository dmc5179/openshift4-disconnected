#!/bin/bash

# Cleanup all Evicted pods

for project in $(oc get pods --all-namespaces| grep Evicted| awk '{print $1}' | uniq)
do

  echo "Cleaning up Evicted pods in project: $project"

  oc delete po $(oc get pods -n $project | grep Evicted| awk '{print $1}') -n $project

done
