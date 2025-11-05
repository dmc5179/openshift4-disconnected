#!/bin/bash

# This command uses a combination of 'oc get secret', 'jq', and 'oc patch' 
# to target and patch Secrets that have a 'certificate-not-after' annotation.

#2025-11-05T00:46:46Z

#date_create=$(oc get -n openshift-kube-controller-manager-operator secret csr-signer-signer -o json | jq -c -r '.metadata.annotations."auth.openshift.io/certificate-not-before"')
#date_rotate=$(oc get -n openshift-kube-controller-manager-operator secret csr-signer-signer -o json | jq -c -r '.metadata.annotations."auth.openshift.io/certificate-not-after"')

#.[] | select(.field_name | contains("substring"))

#oc get secret -A -o json | \
#jq -r '.items[] | select(.metadata.annotations."auth.openshift.io/certificate-not-after" | contains("2025-11-05")) | "-n \(.metadata.namespace) \(.metadata.name)"'

NUM_NS=$(oc get namespaces --no-headers=true -o custom-columns=NAME:.metadata.name | wc -l)
i=1
for ns in $(oc get namespaces --no-headers=true -o custom-columns=NAME:.metadata.name)
#for ns in openshift-kube-apiserver openshift-kube-apiserver-operator openshift-kube-controller-manager openshift-kube-controller-manager-operator
do
  echo "Checking $ns ${i}/${NUM_NS}"
  for s in $(oc get --no-headers=true secrets -n $ns -o custom-columns=NAME:.metadata.name)
  do
    #echo "Namespace: $ns    Secret: $s"
    if oc get -o json -n $ns secret $s | grep -q certificate-not-after
    then
      s_content=$(oc get -o json -n $ns secret $s | jq -c -r '.metadata.annotations."auth.openshift.io/certificate-not-after"')
      if [[ "${s_content}" =~ "2025-11-05" ]]  # TODO, this date is currently hard coded
      then
        echo "match: $ns    $s"
        #echo "Deleting: $ns $s"
        #oc delete -n $ns secret $s
      fi
      #oc get -o json -n $ns secret $s | jq -c -r '. | select(.metadata.annotations."auth.openshift.io/certificate-not-after" | contains("2025-11-05")) | "-n \(.metadata.namespace) \(.metadata.name)"'
    fi
  done
  let i=i+1
done



