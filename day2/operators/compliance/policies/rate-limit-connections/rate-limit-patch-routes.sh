#!/bin/bash


oc get routes --all-namespaces -o json | jq '[.items[] | select(.metadata.namespace | startswith("kube-") or startswith("openshift-") | not) | select(.metadata.annotations["haproxy.router.openshift.io/rate-limit-connections"] == "true" | not) | .metadata.name]'
 
