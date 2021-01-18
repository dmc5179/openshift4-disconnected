#!/bin/bash

# Cleanup projects stuck in the Terminating state

for i in $( kubectl get ns | grep Terminating | awk '{print $1}')
do
  echo $i

  kubectl get ns $i -o json| jq "del(.spec.finalizers[0])"> "$i.json"

  curl -k -H "Authorization: Bearer $(oc whoami -t)" -H "Content-Type: application/json" \
       -X PUT --data-binary @"$i.json" "$(oc config view --minify \
       -o jsonpath='{.clusters[0].cluster.server}')/api/v1/namespaces/$i/finalize"

done


