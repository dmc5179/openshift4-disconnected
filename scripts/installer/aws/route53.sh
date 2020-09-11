#!/bin/bash -xe

# Source the environment file with the default settings
. ../env.sh

INT_LB_ARN=$(aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
      elbv2 describe-load-balancers | jq '.LoadBalancers[] | select(.LoadBalancerName == "caas-int") | .LoadBalancerArn' | tr -d '"')

# Read in the json template
ROUTE53_BATCH_JSON=$(cat dns-record-set.json)

ROUTE53_BATCH_JSON=$(echo "${ROUTE53_BATCH_JSON}" | sed "s|OCP_CLUSTER_NAME|${OCP_CLUSTER_NAME}|g")
ROUTE53_BATCH_JSON=$(echo "${ROUTE53_BATCH_JSON}" | sed "s|OCP_BASE_DOMAIN|${OCP_BASE_DOMAIN}|g")


# TODO: sed these
# API_INT_LB_IP
# API_LB_IP
# HOSTED_ZONE_ID
# APPS_LB_DNS_NAME


aws "${ROUTE53_ENDPOINT}" route53 change-resource-record-sets \
    --hosted-zone-id ${HOSTED_ZONE_ID} --change-batch "${ROUTE53_BATCH_JSON}"
