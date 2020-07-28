#!/bin/bash -x

OCP_BASE_DOMAIN="cia.ic.gov"
OCP_CLUSTER_NAME="caas"

AWS="/home/danclark/.local/lib/aws/bin/aws"
ENDPOINT="https://route53.us-iso-east-1.c2s.ic.gov"
AWS_OPTS="--no-verify-ssl"

HOSTED_ZONE_ID="Z0835546217CN23LPX04U"

for f in bootstrap_record.json master0_record.json master1_record.json master2_record.json worker0_record.json worker1_record.json worker2_record.json
do
  ${AWS} --endpoint-url "${ENDPOINT}" ${AWS_OPTS} route53 change-resource-record-sets --hosted-zone-id "${HOSTED_ZONE_ID}" --change-batch "file://${f}"
  sleep 1
done
