#!/bin/bash

#oc get -o yaml -n openshift-ingress-operator secret cloud-credentials > cloud-credentials-orig.yaml

oc get replicasets,deployments,statefulsets,daemonsets,cronjobs,jobs,pods -n openshift-ingress-operator -o yaml | grep cloud-credentials

oc get replicasets,deployments,statefulsets,daemonsets,cronjobs,jobs,pods -n openshift-ingress-operator -o yaml | grep -i -e "^ name:"  -e "^  kind" -e cloud-credentials


#openshift-cloud-credential-operator secret cloud-credential-operator-iam-ro-creds 

oc get replicasets,deployments,statefulsets,daemonsets,cronjobs,jobs,pods -n openshift-cloud-credential-operator -o yaml | grep cloud-credential-operator-iam-ro-creds

oc get replicasets,deployments,statefulsets,daemonsets,cronjobs,jobs,pods -n openshift-cloud-credential-operator -o yaml | grep -i -e "^ name:"  -e "^  kind" -e cloud-credential-operator-iam-ro-creds
