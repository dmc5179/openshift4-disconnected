#!/bin/bash -x

ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')

for policy in *_policy.json
do

  POLICY_NAME=$(basename $policy _policy.json)

  ACCESS_KEY_ID=$(jq -r '.AccessKey.AccessKeyId' "${POLICY_NAME}_keys.json")

  aws iam delete-access-key --access-key-id "${ACCESS_KEY_ID}" --user-name "${POLICY_NAME}"

  aws iam detach-user-policy --user-name "${POLICY_NAME}" --policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/${POLICY_NAME}"

  aws iam delete-user --user-name "${POLICY_NAME}"

  aws iam delete-policy --policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/${POLICY_NAME}"

done

