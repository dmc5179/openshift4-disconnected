#!/bin/bash -xe

# Source the environment file with the default settings
. ../env.sh

aws --endpoint-url "${ELB_ENDPOINT}" --no-verify-ssl \
    elbv2 create-target-group \
    --name openshift-machineconfig \
    --protocol TCP \
    --port 22623 \
    --target-type ip \
    --vpc-id "${VPC_ID}"

MC_TG_ARN=$(aws --endpoint-url "${ELB_ENDPOINT}" --no-verify-ssl \
    elbv2 describe-target-groups \
    --name openshift-machineconfig \
    --query 'TargetGroups[0].TargetGroupArn' --output text)

aws --endpoint-url "${ELB_ENDPOINT}" --no-verify-ssl \
    elbv2 register-targets \
    --target-group-arn "${MC_TG_ARN}" \
    --targets Id=10.0.106.50 Id=10.0.106.51 Id=10.0.106.52 Id=10.0.106.53

aws --endpoint-url "${ELB_ENDPOINT}" --no-verify-ssl \
    elbv2 create-target-group \
    --name openshift-api \
    --protocol TCP \
    --port 6443 \
    --target-type ip \
    --vpc-id "${VPC_ID}"

API_TG_ARN=$(aws --endpoint-url "${ELB_ENDPOINT}" --no-verify-ssl \
    elbv2 describe-target-groups \
    --name openshift-api \
    --query 'TargetGroups[0].TargetGroupArn' --output text)

aws --endpoint-url "${ELB_ENDPOINT}" --no-verify-ssl \
    elbv2 register-targets \
    --target-group-arn "${API_TG_ARN}" \
    --targets Id=10.0.106.50 Id=10.0.106.51 Id=10.0.106.52 Id=10.0.106.53

aws --endpoint-url "${ELB_ENDPOINT}" --no-verify-ssl \
    elbv2 create-target-group \
    --name openshift-ingress-http \
    --protocol TCP \
    --port 80 \
    --target-type ip \
    --vpc-id "${VPC_ID}"

HTTP_TG_ARN=$(aws --endpoint-url "${ELB_ENDPOINT}" --no-verify-ssl \
    elbv2 describe-target-groups \
    --name openshift-ingress-http \
    --query 'TargetGroups[0].TargetGroupArn' --output text)

aws --endpoint-url "${ELB_ENDPOINT}" --no-verify-ssl \
    elbv2 register-targets \
    --target-group-arn "${HTTP_TG_ARN}" \
    --targets Id=10.0.106.61 Id=10.0.106.62 Id=10.0.106.63

aws --endpoint-url "${ELB_ENDPOINT}" --no-verify-ssl \
    elbv2 create-target-group \
    --name openshift-ingress-https \
    --protocol TCP \
    --port 443 \
    --target-type ip \
    --vpc-id "${VPC_ID}"

HTTPS_TG_ARN=$(aws --endpoint-url "${ELB_ENDPOINT}" --no-verify-ssl \
                   elbv2 describe-target-groups \
                   --name openshift-ingress-https \
                   --query 'TargetGroups[0].TargetGroupArn' --output text)

aws --endpoint-url "${ELB_ENDPOINT}" --no-verify-ssl \
    elbv2 register-targets \
    --target-group-arn "${HTTPS_TG_ARN}" \
    --targets Id=10.0.106.61 Id=10.0.106.62 Id=10.0.106.63


aws --endpoint-url "${ELB_ENDPOINT}" --no-verify-ssl \
    elbv2 create-load-balancer --name openshift-api-mc-lb \
    --type network --subnets "${SUBNET_ID}" --security-groups "${SG_ID}"

API_LB_ARN=$(aws --endpoint-url "${ELB_ENDPOINT}" --no-verify-ssl \
                 elbv2 describe-load-balancers --name openshift-api-mc-lb \
                 --query 'LoadBalancers[0].LoadBalancerArn' --output text)

aws --endpoint-url "${ELB_ENDPOINT}" --no-verify-ssl \
    elbv2 create-listener --load-balancer-arn "${API_LB_ARN}" --protocol TCP --port 6443 \
    --default-actions Type=forward,TargetGroupArn=${API_TG_ARN}

aws --endpoint-url "${ELB_ENDPOINT}" --no-verify-ssl \
    elbv2 create-listener --load-balancer-arn "${API_LB_ARN}" --protocol TCP --port 22623 \
    --default-actions Type=forward,TargetGroupArn=${MC_TG_ARN}

aws --endpoint-url "${ELB_ENDPOINT}" --no-verify-ssl \
    elbv2 create-load-balancer --name openshift-ingress-lb --type network --subnets "${SUBNET_ID}" --security-groups "${SG_ID}"

INGRESS_LB_ARN=$(aws --endpoint-url "${ELB_ENDPOINT}" --no-verify-ssl \
                     elbv2 describe-load-balancers --name openshift-ingress-lb \
                     --query 'LoadBalancers[0].LoadBalancerArn' --output text)

aws --endpoint-url "${ELB_ENDPOINT}" --no-verify-ssl \
    elbv2 create-listener --load-balancer-arn "${INGRESS_LB_ARN}" --protocol TCP --port 80 \
    --default-actions Type=forward,TargetGroupArn=${HTTP_TG_ARN}

aws --endpoint-url "${ELB_ENDPOINT}" --no-verify-ssl \
    elbv2 create-listener --load-balancer-arn "${INGRESS_LB_ARN}" --protocol TCP --port 443 \
    --default-actions Type=forward,TargetGroupArn=${HTTPS_TG_ARN}


aws --endpoint-url 'https://route53.c2s.ic.gov' --no-verify-ssl route53 change-resource-record-sets --hosted-zone-id "${HOSTED_ZONE}" --change-batch file://route53.json


