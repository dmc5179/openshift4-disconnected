#!/bin/bash

#if oc -n openshift-kube-apiserver-operator get secret kube-apiserver-to-kubelet-signer > /dev/null; then
#
#cluster_exp_date=$(oc -n openshift-kube-apiserver-operator get secret kube-apiserver-to-kubelet-signer -o jsonpath='{.metadata.annotations.auth\.openshift\.io/certificate-not-after}')
#
## Convert the target date to a format compatible with date command
#cluster_exp_date_seconds=$(date -d "$cluster_exp_date" +%s)
#
## Get the current date in seconds since epoch
#current_date_seconds=$(date +%s)
#
## Calculate the difference in seconds and then convert to days
#seconds_diff=$((cluster_exp_date_seconds - current_date_seconds))
#days_diff=$((seconds_diff / 86400))
#
#echo "Certificate expiration date of cluster: $cluster_exp_date"
#echo "The cluster certificate will expire in $days_diff days."
#echo "Start the cluster beforehand to ensure the cluster's CA certificate renews automatically."


closest_date="x"
for ns in openshift-kube-apiserver openshift-kube-apiserver-operator openshift-kube-controller-manager openshift-kube-controller-manager-operator
do
  for s in $(oc get --no-headers=true secrets -n $ns -o custom-columns=NAME:.metadata.name)
  do
    #echo "Namespace: $ns    Secret: $s"
    if oc get -o json -n $ns secret $s | grep -q certificate-not-after
    then
      s_content=$(oc get -o json -n $ns secret $s | jq -c -r '.metadata.annotations."auth.openshift.io/certificate-not-after"')
      exp_date_seconds=$(date -d "$s_content" +%s)
      if [[ "$closest_date" == "x" ]]
      then
        closest_date=$exp_date_seconds
      elif [[ $exp_date_seconds < $closest_date ]]
      then
        closest_date=$exp_date_seconds
      fi
      echo "certificate: $ns  :  $s  : $s_content   : $exp_date_seconds"
    fi
  done
done

current_date_seconds=$(date +%s)
seconds_diff=$((closest_date - current_date_seconds))
days_diff=$((seconds_diff / 86400))

echo "Closest date: $(date -d @${closest_date})"


