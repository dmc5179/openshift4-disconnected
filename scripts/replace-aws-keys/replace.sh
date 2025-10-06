#!/bin/bash -xe

# Easier if these are set in your shell to avoid checking them into github
#AWS_ACCESS_KEY_ID="fakekey"
#AWS_SECRET_ACCESS_KEY="fakesec"
#AWS_DEFAULT_REGION="us-east-2"

# Need to base64 encode these values
AWS_ACCESS_KEY_ID_ENCODED=$(echo ${AWS_ACCESS_KEY_ID} | base64 -w0)
AWS_SECRET_ACCESS_KEY_ENCODED=$(echo ${AWS_SECRET_ACCESS_KEY} | base64 -w0)

# Replace the top level aws creds secret for the Credentials Requests
oc get -n kube-system -o yaml secret aws-creds

oc patch -n kube-system secret aws-creds --type='merge' \
  -p '{"data":{"aws_access_key_id":"'"$AWS_ACCESS_KEY_ID_ENCODED"'","aws_secret_access_key":"'"$AWS_SECRET_ACCESS_KEY_ENCODED"'"}}'

# Below this might not be needed but makes the process go more quickly and smoothly

# Need to base64 encode what will be the .aws/credentials file that goes into the secret
credentials=$(cat <<EOF | base64 -w0
[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
EOF
)

# patch the secrets....

# cco-secret #
# Backup the secret
oc get -o yaml -n openshift-cloud-credential-operator secret cloud-credential-operator-iam-ro-creds > cloud-credential-operator-iam-ro-creds-orig.yaml
# Apply the new config
oc patch -n openshift-cloud-credential-operator secret cloud-credential-operator-iam-ro-creds --type='merge' \
  -p '{"data":{"aws_access_key_id":"'"$AWS_ACCESS_KEY_ID_ENCODED"'","aws_secret_access_key":"'"$AWS_SECRET_ACCESS_KEY_ENCODED"'","credentials":"'"$credentials"'"}}'

# ebs-secret #
# Backup the secret
oc get -o yaml -n openshift-cluster-csi-drivers secret ebs-cloud-credentials > ebs-cloud-credentials-orig.yaml
# Apply the new config
oc patch -n openshift-cluster-csi-drivers secret ebs-cloud-credentials --type='merge' \
  -p '{"data":{"aws_access_key_id":"'"$AWS_ACCESS_KEY_ID_ENCODED"'","aws_secret_access_key":"'"$AWS_SECRET_ACCESS_KEY_ENCODED"'","credentials":"'"$credentials"'"}}'
# wait for patch to apply
sleep 4
# delete the node csi driver pods to ensure credentials rotation after controller pods rotate
oc delete pod -l app=aws-ebs-csi-driver-node

# This should cause pods to rotate
#aws-ebs-csi-driver-controller-5d8cd59d8f-dlctj   11/11   Running   0          47s
#aws-ebs-csi-driver-controller-5d8cd59d8f-nqrzd   11/11   Running   0          35s

# image-registry-secret #
# Backup the secret
oc get -o yaml -n openshift-image-registry secret installer-cloud-credentials > installer-cloud-credentials-orig.yaml
# Apply the new config
oc patch -n openshift-image-registry secret installer-cloud-credentials  --type='merge' \
  -p '{"data":{"aws_access_key_id":"'"$AWS_ACCESS_KEY_ID_ENCODED"'","aws_secret_access_key":"'"$AWS_SECRET_ACCESS_KEY_ENCODED"'","credentials":"'"$credentials"'"}}'

# This should cause these pods to rotate
#image-registry-65f7cb59c-b47tc                     1/1     Running     0          5m49s
#image-registry-65f7cb59c-gr7tg                     1/1     Running     0          5m49s

# ingress-secret #
# Backup the secret
oc get -o yaml -n openshift-ingress-operator secret cloud-credentials > cloud-credentials-orig.yaml
# Apply the new config
oc patch -n openshift-ingress-operator secret cloud-credentials --type='merge' \
  -p '{"data":{"aws_access_key_id":"'"$AWS_ACCESS_KEY_ID_ENCODED"'","aws_secret_access_key":"'"$AWS_SECRET_ACCESS_KEY_ENCODED"'","credentials":"'"$credentials"'"}}'

# machine-api-secret #
# Backup the secret
oc get -o yaml -n openshift-machine-api secret aws-cloud-credentials > aws-cloud-credentials-orig.yaml
# Apply the new config
oc patch -n openshift-machine-api secret aws-cloud-credentials --type='merge' \
  -p '{"data":{"aws_access_key_id":"'"$AWS_ACCESS_KEY_ID_ENCODED"'","aws_secret_access_key":"'"$AWS_SECRET_ACCESS_KEY_ENCODED"'","credentials":"'"$credentials"'"}}'

# cloud-network-config-controller #
# Backup the secret
oc get -o yaml -n openshift-cloud-network-config-controller secret cloud-credentials > cloud-credentials-orig.yaml
# Apply the new config
oc patch -n openshift-cloud-network-config-controller secret cloud-credentials --type='merge' \
  -p '{"data":{"aws_access_key_id":"'"$AWS_ACCESS_KEY_ID_ENCODED"'","aws_secret_access_key":"'"$AWS_SECRET_ACCESS_KEY_ENCODED"'","credentials":"'"$credentials"'"}}'

