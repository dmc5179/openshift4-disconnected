#!/bin/bash

for policy in *_policy.json
do

  POLICY_NAME=$(basename $policy _policy.json)

  POLICY_ARN=$(aws iam create-policy --policy-name "${POLICY_NAME}" --policy-document "file://${PWD}/${policy}" | jq -r '.Policy.Arn')

  aws iam create-user --user-name "${POLICY_NAME}"

  aws iam attach-user-policy --policy-arn "${POLICY_ARN}" --user-name "${POLICY_NAME}"

  aws iam create-access-key --user-name "${POLICY_NAME}" > "${POLICY_NAME}_keys.json"

done
