#!/bin/bash

# Easier if these are set in your shell to avoid checking them into github
#AWS_ACCESS_KEY_ID="fakekey"
#AWS_SECRET_ACCESS_KEY="fakesec"
#AWS_DEFAULT_REGION="us-east-2"

# Example of what the secrets look like
#oc get -o yaml -n openshift-cloud-credential-operator Secret cloud-credential-operator-iam-ro-creds
#apiVersion: v1
#data:
#  aws_access_key_id: XXXXXXX=
#  aws_secret_access_key: YYYYY== 
#  credentials: ZZZZZZZ==
#kind: Secret

# Should we base64 encode this first? probably not
credentials=$(cat <<EOF | base64 -w0
[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
EOF
)

# Need to base64 encode these values
AWS_ACCESS_KEY_ID_ENCODED=$(echo ${AWS_ACCESS_KEY_ID} | base64 -w0)
AWS_SECRET_ACCESS_KEY_ENCODED=$(echo ${AWS_SECRET_ACCESS_KEY} | base64 -w0)

# patch the secrets....

#cco-secret # oc get -o yaml -n openshift-cloud-credential-operator secret cloud-credential-operator-iam-ro-creds
oc patch -n openshift-cloud-credential-operator secret cloud-credential-operator-iam-ro-creds --type='merge' \
  -p '{"data":{"aws_access_key_id":"'"$AWS_ACCESS_KEY_ID_ENCODED"'","aws_secret_access_key":"'"$AWS_SECRET_ACCESS_KEY_ENCODED"'","credentials":"'"$credentials"'"}}'

#ebs-secret # oc get -o yaml -n openshift-cluster-csi-drivers secret ebs-cloud-credentials
oc patch -n openshift-cluster-csi-drivers secret ebs-cloud-credentials --type='merge' \
  -p '{"data":{"aws_access_key_id":"'"$AWS_ACCESS_KEY_ID_ENCODED"'","aws_secret_access_key":"'"$AWS_SECRET_ACCESS_KEY_ENCODED"'","credentials":"'"$credentials"'"}}'

# This should cause pods to rotate
#aws-ebs-csi-driver-controller-5d8cd59d8f-dlctj   11/11   Running   0          47s
#aws-ebs-csi-driver-controller-5d8cd59d8f-nqrzd   11/11   Running   0          35s

#image-registry-secret # oc get -o yaml -n openshift-image-registry secret installer-cloud-credentials
oc patch -n openshift-image-registry secret installer-cloud-credentials  --type='merge' \
  -p '{"data":{"aws_access_key_id":"'"$AWS_ACCESS_KEY_ID_ENCODED"'","aws_secret_access_key":"'"$AWS_SECRET_ACCESS_KEY_ENCODED"'","credentials":"'"$credentials"'"}}'

# This should cause these pods to rotate
#image-registry-65f7cb59c-b47tc                     1/1     Running     0          5m49s
#image-registry-65f7cb59c-gr7tg                     1/1     Running     0          5m49s

#ingress-secret # oc get -o yaml -n openshift-ingress-operator secret cloud-credentials
oc patch -n openshift-ingress-operator secret cloud-credentials --type='merge' \
  -p '{"data":{"aws_access_key_id":"'"$AWS_ACCESS_KEY_ID_ENCODED"'","aws_secret_access_key":"'"$AWS_SECRET_ACCESS_KEY_ENCODED"'","credentials":"'"$credentials"'"}}'

#machine-api-secret # oc get -o yaml -n openshift-machine-api secret aws-cloud-credentials
oc patch -n openshift-machine-api secret aws-cloud-credentials --type='merge' \
  -p '{"data":{"aws_access_key_id":"'"$AWS_ACCESS_KEY_ID_ENCODED"'","aws_secret_access_key":"'"$AWS_SECRET_ACCESS_KEY_ENCODED"'","credentials":"'"$credentials"'"}}'

#cloud-network-config-controller # oc get -o yaml -n openshift-cloud-network-config-controller secret cloud-credentials
oc patch -n openshift-cloud-network-config-controller secret cloud-credentials --type='merge' \
  -p '{"data":{"aws_access_key_id":"'"$AWS_ACCESS_KEY_ID_ENCODED"'","aws_secret_access_key":"'"$AWS_SECRET_ACCESS_KEY_ENCODED"'","credentials":"'"$credentials"'"}}'



