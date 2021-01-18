#!/bin/bash

# Cleanup persistent volumes stuck in the Terminating state

for i in $(oc get pvc | grep Terminating| awk '{print $1}')
do

  echo "Cleaning PVC: $i"

  oc patch pvc $i --type='json' -p='[{"op": "replace", "path": "/metadata/finalizers", "value":[]}]'

done

