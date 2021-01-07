#!/bin/bash -xe

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Source the environment file with the default settings
source "${SCRIPT_DIR}/../../../env.sh"

#ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')

for policy in *_policy.json
do

  POLICY_NAME=$(basename $policy _policy.json)

  aws ${IAM_ENDPOINT} ${AWS_OPTS} iam create-policy --policy-name "${POLICY_NAME}" --policy-document "file://${PWD}/${policy}"

  aws ${IAM_ENDPOINT} ${AWS_OPTS} iam create-user --user-name "${POLICY_NAME}"

  aws ${IAM_ENDPOINT} ${AWS_OPTS} iam attach-user-policy --policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/${POLICY_NAME}" --user-name "${POLICY_NAME}"

  aws ${IAM_ENDPOINT} ${AWS_OPTS} iam create-access-key --user-name "${POLICY_NAME}" > "${POLICY_NAME}_keys.json"

done
