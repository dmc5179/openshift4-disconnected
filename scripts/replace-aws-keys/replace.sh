#!/bin/bash

export AWS_ACCESS_KEY_ID="fakekey"
export AWS_SECRET_ACCESS_KEY="fakesec"
export AWS_DEFAULT_REGION="us-east-2"

# Example of what the secrets look like
#oc get -o yaml -n openshift-cloud-credential-operator Secret cloud-credential-operator-iam-ro-creds
#apiVersion: v1
#data:
#  aws_access_key_id: XXXXXXX=
#  aws_secret_access_key: YYYYY== 
#  credentials: ZZZZZZZ==
#kind: Secret

# Should we base64 encode this first? probably not
credentials=$(echo <<EOF
[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
EOF
)

# patch the secrets....

#cco-secret # oc get -o yaml -n openshift-cloud-credential-operator secret cloud-credential-operator-iam-ro-creds
oc patch -n openshift-cloud-credential-operator secret cloud-credential-operator-iam-ro-creds --type='merge' \
  -p '{"data":{"aws_access_key_id":"'"$AWS_ACCESS_KEY_ID"'","aws_secret_access_key":"'"$AWS_SECRET_ACCESS_KEY"'","credentials":"'"$credentials"'"}}'

#ebs-secret # oc get -o yaml -n openshift-cluster-csi-drivers secret ebs-cloud-credentials
oc patch -n openshift-cluster-csi-drivers secret ebs-cloud-credentials --type='merge' \
  -p '{"data":{"aws_access_key_id":"'"$AWS_ACCESS_KEY_ID"'","aws_secret_access_key":"'"$AWS_SECRET_ACCESS_KEY"'","credentials":"'"$credentials"'"}}'

#image-registry-secret # oc get -o yaml -n openshift-image-registry secret installer-cloud-credentials
oc patch -n openshift-image-registry secret installer-cloud-credentials  --type='merge' \
  -p '{"data":{"aws_access_key_id":"'"$AWS_ACCESS_KEY_ID"'","aws_secret_access_key":"'"$AWS_SECRET_ACCESS_KEY"'","credentials":"'"$credentials"'"}}'

#ingress-secret # oc get -o yaml -n openshift-ingress-operator secret cloud-credentials
oc patch -n openshift-ingress-operator secret cloud-credentials --type='merge' \
  -p '{"data":{"aws_access_key_id":"'"$AWS_ACCESS_KEY_ID"'","aws_secret_access_key":"'"$AWS_SECRET_ACCESS_KEY"'","credentials":"'"$credentials"'"}}'

#machine-api-secret # oc get -o yaml -n openshift-machine-api secret aws-cloud-credentials
oc patch -n openshift-machine-api secret aws-cloud-credentials --type='merge' \
  -p '{"data":{"aws_access_key_id":"'"$AWS_ACCESS_KEY_ID"'","aws_secret_access_key":"'"$AWS_SECRET_ACCESS_KEY"'","credentials":"'"$credentials"'"}}'

#cloud-network-config-controller # oc get -o yaml -n openshift-cloud-network-config-controller secret cloud-credentials
oc patch -n openshift-cloud-network-config-controller secret cloud-credentials --type='merge' \
  -p '{"data":{"aws_access_key_id":"'"$AWS_ACCESS_KEY_ID"'","aws_secret_access_key":"'"$AWS_SECRET_ACCESS_KEY"'","credentials":"'"$credentials"'"}}'



