#!/bin/bash

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

rm ${CLUSTER_DIR}/openshift/99_cloud-creds-secret.yaml
