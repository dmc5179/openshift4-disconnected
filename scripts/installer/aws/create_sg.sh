#!/bin/bash -xe

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Source the environment file with the default settings
source "${SCRIPT_DIR}/../env.sh"

# Check if the security group exists already.
K8S_ELB_SG=$(aws ${EC2_ENDPOINT} ${AWS_OPTS} ec2 describe-security-groups \
  | jq ".SecurityGroups[] | select(.GroupName == \"${OCP_CLUSTER_NAME}-k8s-elb\") | .GroupId" | tr -d '"')

# Check if the security group exists already.
K8S_MASTER_SG=$(aws ${EC2_ENDPOINT} ${AWS_OPTS} ec2 describe-security-groups \
  | jq ".SecurityGroups[] | select(.GroupName == \"${OCP_CLUSTER_NAME}-k8s-master\") | .GroupId" | tr -d '"')

# Check if the security group exists already.
K8S_WORKER_SG=$(aws ${EC2_ENDPOINT} ${AWS_OPTS} ec2 describe-security-groups \
  | jq ".SecurityGroups[] | select(.GroupName == \"${OCP_CLUSTER_NAME}-k8s-worker\") | .GroupId" | tr -d '"')


# If it doesn't exist, create it
if [ -z "${K8S_ELB_SG}" ]
then

  aws ${EC2_ENDPOINT} ${AWS_OPTS} ec2 create-security-group \
      --description "Security group for (openshift-ingress/router-default)" \
      --group-name "${OCP_CLUSTER_NAME}-k8s-elb" \
      --vpc-id "${VPC_ID}"

  K8S_ELB_SG=$(aws ${EC2_ENDPOINT} ${AWS_OPTS} ec2 describe-security-groups \
    | jq ".SecurityGroups[] | select(.GroupName == \"${OCP_CLUSTER_NAME}-k8s-elb\") | .GroupId" | tr -d '"')

  aws ${EC2_ENDPOINT} ${AWS_OPTS} ec2 authorize-security-group-ingress \
      --group-id ${K8S_ELB_SG} \
      --cli-input-json "$(cat k8s-elb-sg.json)"

fi

# If it doesn't exist, create it
if [ -z "${K8S_MASTER_SG}" ]
then

  aws ${EC2_ENDPOINT} ${AWS_OPTS} ec2 create-security-group \
      --description "Security group for openshift master nodes" \
      --group-name "${OCP_CLUSTER_NAME}-k8s-master" \
      --vpc-id "${VPC_ID}"

  K8S_MASTER_SG=$(aws ${EC2_ENDPOINT} ${AWS_OPTS} ec2 describe-security-groups \
    | jq ".SecurityGroups[] | select(.GroupName == \"${OCP_CLUSTER_NAME}-k8s-master\") | .GroupId" | tr -d '"')

fi

# If it doesn't exist, create it
if [ -z "${K8S_WORKER_SG}" ]
then

  aws ${EC2_ENDPOINT} ${AWS_OPTS} ec2 create-security-group \
      --description "Security group for openshift worker nodes" \
      --group-name "${OCP_CLUSTER_NAME}-k8s-worker" \
      --vpc-id "${VPC_ID}"

  K8S_WORKER_SG=$(aws ${EC2_ENDPOINT} ${AWS_OPTS} ec2 describe-security-groups \
    | jq ".SecurityGroups[] | select(.GroupName == \"${OCP_CLUSTER_NAME}-k8s-worker\") | .GroupId" | tr -d '"')

fi

rm -f /tmp/masters-sg.json
cp masters-sg.json /tmp/masters-sg.json
sed -i "s|MASTER_SG|${K8S_MASTER_SG}|g" /tmp/masters-sg.json
sed -i "s|WORKER_SG|${K8S_WORKER_SG}|g" /tmp/masters-sg.json
sed -i "s|AWS_ACCT_ID|${AWS_ACCT_ID}|g" /tmp/masters-sg.json
sed -i "s|CLUSTER_NAME|${OCP_CLUSTER_NAME}|g" /tmp/masters-sg.json
sed -i "s|VPC_ID|${VPC_ID}|g" /tmp/masters-sg.json
sed -i "s|K8S_ELB_SG|${K8S_ELB_SG}|g" /tmp/masters-sg.json

aws ${EC2_ENDPOINT} ${AWS_OPTS} ec2 authorize-security-group-ingress \
    --group-id ${K8S_MASTER_SG} \
    --cli-input-json "$(cat /tmp/masters-sg.json)"

#rm -f /tmp/masters-sg.json

rm -f /tmp/workers-sg.json
cp workers-sg.json /tmp/workers-sg.json
sed -i "s|MASTER_SG|${K8S_MASTER_SG}|g" /tmp/workers-sg.json
sed -i "s|WORKER_SG|${K8S_WORKER_SG}|g" /tmp/workers-sg.json
sed -i "s|AWS_ACCT_ID|${AWS_ACCT_ID}|g" /tmp/workers-sg.json
sed -i "s|CLUSTER_NAME|${OCP_CLUSTER_NAME}|g" /tmp/workers-sg.json
sed -i "s|VPC_ID|${VPC_ID}|g" /tmp/workers-sg.json
sed -i "s|K8S_ELB_SG|${K8S_ELB_SG}|g" /tmp/workers-sg.json

aws ${EC2_ENDPOINT} ${AWS_OPTS} ec2 authorize-security-group-ingress \
    --group-id ${K8S_WORKER_SG} \
    --cli-input-json "$(cat /tmp/workers-sg.json)"

exit 0
