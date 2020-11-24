#!/bin/bash -xe

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Source the environment file with the default settings
source "${SCRIPT_DIR}/../../env.sh"

INT_LB_DNS=$(aws ${ELB_ENDPOINT} ${AWS_OPTS} \
      elbv2 describe-load-balancers | jq ".LoadBalancers[] | select(.LoadBalancerName == \"${OCP_CLUSTER_NAME}-int\") | .DNSName" | tr -d '"')

INT_LB_HZ=$(aws ${ELB_ENDPOINT} ${AWS_OPTS} \
      elbv2 describe-load-balancers | jq ".LoadBalancers[] | select(.LoadBalancerName == \"${OCP_CLUSTER_NAME}-int\") | .CanonicalHostedZoneId" | tr -d '"')



EXT_LB_DNS=$(aws ${ELB_ENDPOINT} ${AWS_OPTS} \
    elbv2 describe-load-balancers | jq ".LoadBalancers[] | select(.LoadBalancerName == \"${OCP_CLUSTER_NAME}-ext\") | .DNSName" | tr -d '"')

EXT_LB_HZ=$(aws ${ELB_ENDPOINT} ${AWS_OPTS} \
    elbv2 describe-load-balancers | jq ".LoadBalancers[] | select(.LoadBalancerName == \"${OCP_CLUSTER_NAME}-ext\") | .CanonicalHostedZoneId" | tr -d '"')



INGRESS_LB_DNS=$(aws ${ELB_ENDPOINT} ${AWS_OPTS} \
    elb describe-load-balancers | jq ".LoadBalancerDescriptions[] | select(.LoadBalancerName == \"${OCP_CLUSTER_NAME}-ingress\") | .DNSName" | tr -d '"')

INGRESS_LB_HZ=$(aws ${ELB_ENDPOINT} ${AWS_OPTS} \
    elb describe-load-balancers | jq ".LoadBalancerDescriptions[] | select(.LoadBalancerName == \"${OCP_CLUSTER_NAME}-ingress\") | .CanonicalHostedZoneNameID" | tr -d '"')

# Read in the json template
ROUTE53_BATCH_JSON=$(cat dns-record-set.json)

ROUTE53_BATCH_JSON=$(echo "${ROUTE53_BATCH_JSON}" | sed "s|OCP_CLUSTER_NAME|${OCP_CLUSTER_NAME}|g")
ROUTE53_BATCH_JSON=$(echo "${ROUTE53_BATCH_JSON}" | sed "s|OCP_BASE_DOMAIN|${OCP_BASE_DOMAIN}|g")
ROUTE53_BATCH_JSON=$(echo "${ROUTE53_BATCH_JSON}" | sed "s|HOSTED_ZONE_ID|${HOSTED_ZONE_ID}|g")

ROUTE53_BATCH_JSON=$(echo "${ROUTE53_BATCH_JSON}" | sed "s|API_INT_LB_DNS|${INT_LB_DNS}|g")
ROUTE53_BATCH_JSON=$(echo "${ROUTE53_BATCH_JSON}" | sed "s|API_INT_LB_HZ|${INT_LB_HZ}|g")


ROUTE53_BATCH_JSON=$(echo "${ROUTE53_BATCH_JSON}" | sed "s|APPS_EXT_LB_DNS|${EXT_LB_DNS}|g")
ROUTE53_BATCH_JSON=$(echo "${ROUTE53_BATCH_JSON}" | sed "s|APPS_EXT_LB_HZ|${EXT_LB_HZ}|g")


ROUTE53_BATCH_JSON=$(echo "${ROUTE53_BATCH_JSON}" | sed "s|INGRESS_LB_DNS|${INGRESS_LB_DNS}|g")
ROUTE53_BATCH_JSON=$(echo "${ROUTE53_BATCH_JSON}" | sed "s|INGRESS_LB_HZ|${INGRESS_LB_HZ}|g")


echo ${ROUTE53_BATCH_JSON} | jq '.'

aws ${ROUTE53_ENDPOINT} route53 change-resource-record-sets \
    --hosted-zone-id ${HOSTED_ZONE_ID} --change-batch "${ROUTE53_BATCH_JSON}"
