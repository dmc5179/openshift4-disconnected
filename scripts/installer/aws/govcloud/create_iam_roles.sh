#!/bin/bash

ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')

for policy in *_policy.json
do

  POLICY_NAME=$(basename $policy _policy.json)

  aws iam create-policy --policy-name "${POLICY_NAME}" --policy-document "file://${PWD}/${policy}"

  aws iam create-user --user-name "${POLICY_NAME}"

  aws iam attach-user-policy --policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/${POLICY_NAME}" --user-name "${POLICY_NAME}"

  aws iam create-access-key --user-name "${POLICY_NAME}" > "${POLICY_NAME}_keys.json"

done
