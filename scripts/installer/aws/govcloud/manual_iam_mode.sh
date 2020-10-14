#!/bin/bash

# https://docs.openshift.com/container-platform/4.5/installing/installing_aws/manually-creating-iam.html

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Source the environment file with the default settings
#source "${SCRIPT_DIR}/../../env.sh"

CLUSTER_DIR='/home/ec2-user/workspace/openshift4-disconnected/scripts/installer/aws/govcloud/cluster'
rm -rf "${CLUSTER_DIR}"
mkdir "${CLUSTER_DIR}"

cp ~/install-config.yaml "${CLUSTER_DIR}/"

openshift-install create manifests --dir=${CLUSTER_DIR}

cat <<EOF > ${CLUSTER_DIR}/manifests/cco-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cloud-credential-operator-config
  namespace: openshift-cloud-credential-operator
  annotations:
    release.openshift.io/create-only: "true"
data:
  disabled: "true"
EOF

rm -f ${CLUSTER_DIR}/openshift/99_cloud-creds-secret.yaml

IAM_FILES=$(find release-image/ -type f -exec grep -l 'AWSProviderSpec' '{}' ';')

for f in ${IAM_FILES}
do

  # TODO: This is not a good way to do this
  # In all of the files now, AWS is the first one but that may not always be true
  POLICY_NAME=$(yq -r '.metadata.name' "${f}" | grep -v null | head -1)

  SECRET_NAME=$(yq -r '.spec.secretRef.name' "${f}" | grep -v null | head -1)
  SECRET_NAMESPACE=$(yq -r '.spec.secretRef.namespace' "${f}" | grep -v null | head -1)
  ACCESS_KEY=$(jq -r '.AccessKey.AccessKeyId' "${POLICY_NAME}_keys.json")
  SECRET_KEY=$(jq -r '.AccessKey.SecretAccessKeyId' "${POLICY_NAME}_keys.json")


cat << EOF > "${CLUSTER_DIR}/openshift/99_${POLICY_NAME}-secret.yaml"
kind: Secret
apiVersion: v1
metadata:
  namespace: ${SECRET_NAMESPACE}
  name: ${SECRET_NAME}
data:
  aws_access_key_id: ${ACCESS_KEY}
  aws_secret_access_key: ${SECRET_KEY}
EOF

done
