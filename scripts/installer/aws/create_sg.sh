#!/bin/bash -xe

# Source the environment file with the default settings
. ../env.sh

# Check if the security group exists already.
K8S_ELB_SG=$(aws --endpoint-url "${EC2_ENDPOINT}" ${AWS_OPTS} ec2 describe-security-groups \
  | jq '.SecurityGroups[] | select(.GroupName == "caas-k8s-elb") | .GroupId' | tr -d '"')

# Check if the security group exists already.
K8S_MASTER_SG=$(aws --endpoint-url "${EC2_ENDPOINT}" ${AWS_OPTS} ec2 describe-security-groups \
  | jq '.SecurityGroups[] | select(.GroupName == "caas-k8s-master") | .GroupId' | tr -d '"')

# Check if the security group exists already.
K8S_WORKER_SG=$(aws --endpoint-url "${EC2_ENDPOINT}" ${AWS_OPTS} ec2 describe-security-groups \
  | jq '.SecurityGroups[] | select(.GroupName == "caas-k8s-worker") | .GroupId' | tr -d '"')


#echo "1: ${K8S_ELB_SG}"
#echo "2: ${K8S_MASTER_SG}"
#echo "3: ${K8S_WORKER_SG}"

# If it doesn't exist, create it
if [ -z "${K8S_ELB_SG}" ]
then

  aws --endpoint-url "${EC2_ENDPOINT}" ${AWS_OPTS} ec2 create-security-group \
      --description "Security group for (openshift-ingress/router-default)" \
      --group-name "${OCP_CLUSTER_NAME}-k8s-elb" \
      --vpc-id "${VPC_ID}"

fi

# If it doesn't exist, create it
if [ -z "${K8S_MASTER_SG}" ]
then

  aws --endpoint-url "${EC2_ENDPOINT}" ${AWS_OPTS} ec2 create-security-group \
      --description "Security group for openshift master nodes" \
      --group-name "${OCP_CLUSTER_NAME}-k8s-master" \
      --vpc-id "${VPC_ID}"

fi

# If it doesn't exist, create it
if [ -z "${K8S_WORKER_SG}" ]
then

  aws --endpoint-url "${EC2_ENDPOINT}" ${AWS_OPTS} ec2 create-security-group \
      --description "Security group for openshift worker nodes" \
      --group-name "${OCP_CLUSTER_NAME}-k8s-worker" \
      --vpc-id "${VPC_ID}"

fi

aws --endpoint-url "${EC2_ENDPOINT}" ${AWS_OPTS} ec2 authorize-security-group-ingress \
    --group-id ${K8S_ELB_SG} \
    --cli-input-json "$(cat k8s-elb-sg.json)"
