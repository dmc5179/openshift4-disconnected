#!/bin/bash -xe

# Source the environment file with the default settings
. ../env.sh

aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
    elbv2 create-target-group \
    --name  "${OCP_CLUSTER_NAME}-api-ext" \
    --protocol TCP \
    --port 6443 \
    --target-type ip \
    --vpc-id "${VPC_ID}"

aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
    elbv2 create-target-group \
    --name "${OCP_CLUSTER_NAME}-api-int" \
    --protocol TCP \
    --port 6443 \
    --target-type ip \
    --vpc-id "${VPC_ID}"

aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
    elbv2 create-target-group \
    --name "${OCP_CLUSTER_NAME}-sint" \
    --protocol TCP \
    --port 22623 \
    --target-type ip \
    --vpc-id "${VPC_ID}"


API_EXT_TG_ARN=$(aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
    elbv2 describe-target-groups \
    --name "${OCP_CLUSTER_NAME}-api-ext" \
    --query 'TargetGroups[0].TargetGroupArn' --output text)

API_INT_TG_ARN=$(aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
    elbv2 describe-target-groups \
    --name "${OCP_CLUSTER_NAME}-api-int" \
    --query 'TargetGroups[0].TargetGroupArn' --output text)

S_INT_TG_ARN=$(aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
    elbv2 describe-target-groups \
    --name "${OCP_CLUSTER_NAME}-sint" \
    --query 'TargetGroups[0].TargetGroupArn' --output text)



aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
    elbv2 register-targets \
    --target-group-arn "${API_EXT_TG_ARN}" \
    --targets Id=${BOOTSTRAP_IP} Id=${MASTER0_IP} Id=${MASTER1_IP} Id=${MASTER2_IP}

aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
    elbv2 register-targets \
    --target-group-arn "${API_INT_TG_ARN}" \
    --targets Id=${BOOTSTRAP_IP} Id=${MASTER0_IP} Id=${MASTER1_IP} Id=${MASTER2_IP}

aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
    elbv2 register-targets \
    --target-group-arn "${S_INT_TG_ARN}" \
    --targets Id=${BOOTSTRAP_IP} Id=${MASTER0_IP} Id=${MASTER1_IP} Id=${MASTER2_IP}



# Check if the security group exists already.
K8S_ELB_SG=$(aws --endpoint-url "${EC2_ENDPOINT}" ${AWS_OPTS} ec2 describe-security-groups \
  | jq '.SecurityGroups[] | select(.GroupName == "caas-k8s-elb") | .GroupId' | tr -d '"')

# Check if the security group exists already.
K8S_MASTER_SG=$(aws --endpoint-url "${EC2_ENDPOINT}" ${AWS_OPTS} ec2 describe-security-groups \
  | jq '.SecurityGroups[] | select(.GroupName == "caas-k8s-master") | .GroupId' | tr -d '"')

# Check if the security group exists already.
K8S_WORKER_SG=$(aws --endpoint-url "${EC2_ENDPOINT}" ${AWS_OPTS} ec2 describe-security-groups \
  | jq '.SecurityGroups[] | select(.GroupName == "caas-k8s-worker") | .GroupId' | tr -d '"')


INT_LB_ARN=$(aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
    elbv2 describe-load-balancers | jq '.LoadBalancers[] | select(.LoadBalancerName == "caas-int") | .LoadBalancerArn' | tr -d '"')

if [ -z "${INT_LB_ARN}" ]
then

  aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
      elbv2 create-load-balancer --name "${OCP_CLUSTER_NAME}-int" \
      --type network --subnets "${SUBNET_ID}"

  INT_LB_ARN=$(aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
      elbv2 describe-load-balancers | jq '.LoadBalancers[] | select(.LoadBalancerName == "caas-int") | .LoadBalancerArn' | tr -d '"')

  # Add the target groups aint and sint
  aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
      elbv2 add-listener --load-balaner-arn "${INT_LB_ARN}" \
      --port 6443 --protocol tcp \
      --default-action "Type=forward,TargetGroupArn=${API_INT_TG_ARN}"

  aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
      elbv2 add-listener --load-balaner-arn "${INT_LB_ARN}" \
      --port 22623 --protocol tcp \
      --default-action "Type=forward,TargetGroupArn=${S_INT_TG_ARN}"
fi


EXT_LB_ARN=$(aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
    elbv2 describe-load-balancers | jq '.LoadBalancers[] | select(.LoadBalancerName == "caas-ext") | .LoadBalancerArn' | tr -d '"')

if [ -z "${EXT_LB_ARN}" ]
then

  aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
      elbv2 create-load-balancer --name "${OCP_CLUSTER_NAME}-ext}" \
      --type network --subnets "${SUBNET_ID}"

  EXT_LB_ARN=$(aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
      elbv2 describe-load-balancers | jq '.LoadBalancers[] | select(.LoadBalancerName == "caas-ext") | .LoadBalancerArn' | tr -d '"')

  # Add the target group aext
  aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
      elbv2 add-listener --load-balaner-arn "${EXT_LB_ARN}" \
      --port 6443 --protocol tcp \
      --default-action "Type=forward,TargetGroupArn=${API_EXT_TG_ARN}"
fi

INGRESS_LB_ARN=$(aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
    elb describe-load-balancers | jq '.LoadBalancers[] | select(.LoadBalancerName == "caas-ingress") | .LoadBalancerArn' | tr -d '"')

if [ -z "${INGRESS_LB_ARN}" ]
then

  aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
      elb create-load-balancer --load-balancer-name "${OCP_CLUSTER_NAME}-ingress" \
      --subnets "${SUBNET_ID}" --security-groups "${K8S_ELB_SG}"

  # TODO: Add all nodes to the ingress load balancer above. Use IPs or instance IDs?

fi
