#!/bin/bash -xe

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Source the environment file with the default settings
source "${SCRIPT_DIR}/../env.sh"

aws ${ELB_ENDPOINT} ${AWS_OPTS} \
    elbv2 create-target-group \
    --name  "${OCP_CLUSTER_NAME}-api-ext" \
    --protocol TCP \
    --port 6443 \
    --target-type ip \
    --vpc-id "${VPC_ID}"

aws ${ELB_ENDPOINT} ${AWS_OPTS} \
    elbv2 create-target-group \
    --name "${OCP_CLUSTER_NAME}-api-int" \
    --protocol TCP \
    --port 6443 \
    --target-type ip \
    --vpc-id "${VPC_ID}"

aws ${ELB_ENDPOINT} ${AWS_OPTS} \
    elbv2 create-target-group \
    --name "${OCP_CLUSTER_NAME}-sint" \
    --protocol TCP \
    --port 22623 \
    --target-type ip \
    --vpc-id "${VPC_ID}"


API_EXT_TG_ARN=$(aws ${ELB_ENDPOINT} ${AWS_OPTS} \
    elbv2 describe-target-groups \
    --name "${OCP_CLUSTER_NAME}-api-ext" \
    --query 'TargetGroups[0].TargetGroupArn' --output text)

API_INT_TG_ARN=$(aws ${ELB_ENDPOINT} ${AWS_OPTS} \
    elbv2 describe-target-groups \
    --name "${OCP_CLUSTER_NAME}-api-int" \
    --query 'TargetGroups[0].TargetGroupArn' --output text)

S_INT_TG_ARN=$(aws ${ELB_ENDPOINT} ${AWS_OPTS} \
    elbv2 describe-target-groups \
    --name "${OCP_CLUSTER_NAME}-sint" \
    --query 'TargetGroups[0].TargetGroupArn' --output text)



aws ${ELB_ENDPOINT} ${AWS_OPTS} \
    elbv2 register-targets \
    --target-group-arn "${API_EXT_TG_ARN}" \
    --targets Id=${BOOTSTRAP_IP} Id=${MASTER0_IP} Id=${MASTER1_IP} Id=${MASTER2_IP}

aws ${ELB_ENDPOINT} ${AWS_OPTS} \
    elbv2 register-targets \
    --target-group-arn "${API_INT_TG_ARN}" \
    --targets Id=${BOOTSTRAP_IP} Id=${MASTER0_IP} Id=${MASTER1_IP} Id=${MASTER2_IP}

aws ${ELB_ENDPOINT} ${AWS_OPTS} \
    elbv2 register-targets \
    --target-group-arn "${S_INT_TG_ARN}" \
    --targets Id=${BOOTSTRAP_IP} Id=${MASTER0_IP} Id=${MASTER1_IP} Id=${MASTER2_IP}



# Check if the security group exists already.
K8S_ELB_SG=$(aws ${EC2_ENDPOINT} ${AWS_OPTS} ec2 describe-security-groups \
  | jq ".SecurityGroups[] | select(.GroupName == \"${OCP_CLUSTER_NAME}-k8s-elb\") | .GroupId" | tr -d '"')

# Check if the security group exists already.
K8S_MASTER_SG=$(aws ${EC2_ENDPOINT} ${AWS_OPTS} ec2 describe-security-groups \
  | jq ".SecurityGroups[] | select(.GroupName == \"${OCP_CLUSTER_NAME}-k8s-master\") | .GroupId" | tr -d '"')

# Check if the security group exists already.
K8S_WORKER_SG=$(aws ${EC2_ENDPOINT} ${AWS_OPTS} ec2 describe-security-groups \
  | jq ".SecurityGroups[] | select(.GroupName == \"${OCP_CLUSTER_NAME}-k8s-worker\") | .GroupId" | tr -d '"')


INT_LB_ARN=$(aws ${ELB_ENDPOINT} ${AWS_OPTS} \
    elbv2 describe-load-balancers | jq ".LoadBalancers[] | select(.LoadBalancerName == \"${OCP_CLUSTER_NAME}-int\") | .LoadBalancerArn" | tr -d '"')

if [ -z "${INT_LB_ARN}" ]
then

  aws ${ELB_ENDPOINT} ${AWS_OPTS} \
      elbv2 create-load-balancer --name "${OCP_CLUSTER_NAME}-int" \
      --type network --scheme internal --subnet-mappings "SubnetId=${EC2_SUBNET},PrivateIPv4Address=10.0.106.41"

  INT_LB_ARN=$(aws ${ELB_ENDPOINT} ${AWS_OPTS} \
      elbv2 describe-load-balancers | jq ".LoadBalancers[] | select(.LoadBalancerName == \"${OCP_CLUSTER_NAME}-int\") | .LoadBalancerArn" | tr -d '"')
fi

  # Add the target groups aint and sint
  aws ${ELB_ENDPOINT} ${AWS_OPTS} \
      elbv2 create-listener --load-balancer-arn "${INT_LB_ARN}" \
      --port 6443 --protocol TCP \
      --default-action "Type=forward,TargetGroupArn=${API_INT_TG_ARN}"

  aws ${ELB_ENDPOINT} ${AWS_OPTS} \
      elbv2 create-listener --load-balancer-arn "${INT_LB_ARN}" \
      --port 22623 --protocol TCP \
      --default-action "Type=forward,TargetGroupArn=${S_INT_TG_ARN}"

EXT_LB_ARN=$(aws ${ELB_ENDPOINT} ${AWS_OPTS} \
    elbv2 describe-load-balancers | jq ".LoadBalancers[] | select(.LoadBalancerName == \"${OCP_CLUSTER_NAME}-ext\") | .LoadBalancerArn" | tr -d '"')

if [ -z "${EXT_LB_ARN}" ]
then

  aws ${ELB_ENDPOINT} ${AWS_OPTS} \
      elbv2 create-load-balancer --name "${OCP_CLUSTER_NAME}-ext" \
      --type network --scheme internal --subnet-mappings "SubnetId=${EC2_SUBNET},PrivateIPv4Address=10.0.106.42"

  EXT_LB_ARN=$(aws ${ELB_ENDPOINT} ${AWS_OPTS} \
      elbv2 describe-load-balancers | jq ".LoadBalancers[] | select(.LoadBalancerName == \"${OCP_CLUSTER_NAME}-ext\") | .LoadBalancerArn" | tr -d '"')

fi

  # Add the target group aext
  aws ${ELB_ENDPOINT} ${AWS_OPTS} \
      elbv2 create-listener --load-balancer-arn "${EXT_LB_ARN}" \
      --port 6443 --protocol TCP \
      --default-action "Type=forward,TargetGroupArn=${API_EXT_TG_ARN}"

INGRESS_LB_ARN=$(aws ${ELB_ENDPOINT} ${AWS_OPTS} \
    elb describe-load-balancers | jq ".LoadBalancers[] | select(.LoadBalancerName == \"${OCP_CLUSTER_NAME}-ingress\") | .LoadBalancerArn" | tr -d '"')

if [ -z "${INGRESS_LB_ARN}" ]
then

  aws ${ELB_ENDPOINT} ${AWS_OPTS} \
      elb create-load-balancer --load-balancer-name "${OCP_CLUSTER_NAME}-ingress" --scheme internal \
      --subnets "${EC2_SUBNET}" --security-groups "${K8S_ELB_SG}" --listeners "$(cat ingress-listeners.json)"

fi
