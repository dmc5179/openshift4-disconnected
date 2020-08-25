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


aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
    elbv2 create-load-balancer --name "${OCP_CLUSTER_NAME}-int" \
    --type network --subnets "${SUBNET_ID}" --security-groups "${SG_ID}"

aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
    elbv2 create-load-balancer --name "${OCP_CLUSTER_NAME}-ext}" \
    --type network --subnets "${SUBNET_ID}" --security-groups "${SG_ID}"

aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
    elbv2 create-load-balancer --name "${OCP_CLUSTER_NAME}-ingress" \
    --type classic --subnets "${SUBNET_ID}" --security-groups "${SG_ID}"




#########

MC_TG_ARN=$(aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
    elbv2 describe-target-groups \
    --name openshift-machineconfig \
    --query 'TargetGroups[0].TargetGroupArn' --output text)

aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
    elbv2 register-targets \
    --target-group-arn "${MC_TG_ARN}" \
    --targets Id=10.0.106.50 Id=10.0.106.51 Id=10.0.106.52 Id=10.0.106.53

aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
    elbv2 create-target-group \
    --name openshift-api \
    --protocol TCP \
    --port 6443 \
    --target-type ip \
    --vpc-id "${VPC_ID}"

API_TG_ARN=$(aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
    elbv2 describe-target-groups \
    --name openshift-api \
    --query 'TargetGroups[0].TargetGroupArn' --output text)

aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
    elbv2 register-targets \
    --target-group-arn "${API_TG_ARN}" \
    --targets Id=10.0.106.50 Id=10.0.106.51 Id=10.0.106.52 Id=10.0.106.53

aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
    elbv2 create-target-group \
    --name openshift-ingress-http \
    --protocol TCP \
    --port 80 \
    --target-type ip \
    --vpc-id "${VPC_ID}"

HTTP_TG_ARN=$(aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
    elbv2 describe-target-groups \
    --name openshift-ingress-http \
    --query 'TargetGroups[0].TargetGroupArn' --output text)

aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
    elbv2 register-targets \
    --target-group-arn "${HTTP_TG_ARN}" \
    --targets Id=10.0.106.61 Id=10.0.106.62 Id=10.0.106.63

aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
    elbv2 create-target-group \
    --name openshift-ingress-https \
    --protocol TCP \
    --port 443 \
    --target-type ip \
    --vpc-id "${VPC_ID}"

HTTPS_TG_ARN=$(aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
                   elbv2 describe-target-groups \
                   --name openshift-ingress-https \
                   --query 'TargetGroups[0].TargetGroupArn' --output text)

aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
    elbv2 register-targets \
    --target-group-arn "${HTTPS_TG_ARN}" \
    --targets Id=10.0.106.61 Id=10.0.106.62 Id=10.0.106.63


aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
    elbv2 create-load-balancer --name openshift-api-mc-lb \
    --type network --subnets "${SUBNET_ID}" --security-groups "${SG_ID}"

API_LB_ARN=$(aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
                 elbv2 describe-load-balancers --name openshift-api-mc-lb \
                 --query 'LoadBalancers[0].LoadBalancerArn' --output text)

aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
    elbv2 create-listener --load-balancer-arn "${API_LB_ARN}" --protocol TCP --port 6443 \
    --default-actions Type=forward,TargetGroupArn=${API_TG_ARN}

aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
    elbv2 create-listener --load-balancer-arn "${API_LB_ARN}" --protocol TCP --port 22623 \
    --default-actions Type=forward,TargetGroupArn=${MC_TG_ARN}

aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
    elbv2 create-load-balancer --name openshift-ingress-lb --type network --subnets "${SUBNET_ID}" --security-groups "${SG_ID}"

INGRESS_LB_ARN=$(aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
                     elbv2 describe-load-balancers --name openshift-ingress-lb \
                     --query 'LoadBalancers[0].LoadBalancerArn' --output text)

aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
    elbv2 create-listener --load-balancer-arn "${INGRESS_LB_ARN}" --protocol TCP --port 80 \
    --default-actions Type=forward,TargetGroupArn=${HTTP_TG_ARN}

aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
    elbv2 create-listener --load-balancer-arn "${INGRESS_LB_ARN}" --protocol TCP --port 443 \
    --default-actions Type=forward,TargetGroupArn=${HTTPS_TG_ARN}


aws --endpoint-url 'https://route53.c2s.ic.gov' ${AWS_OPTS} route53 change-resource-record-sets --hosted-zone-id "${HOSTED_ZONE}" --change-batch file://route53.json


