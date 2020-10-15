#!/bin/bash

# This script generates the IAM policy documents
# They can be used to create the IAM policies
# No calls to create the policies exist in this script

# csplit 0000_50_cloud-credential-operator_07_cred-iam-ro.yaml '/^---/' '{*}'
# yq -r 'select(.spec.providerSpec.kind == "AWSProviderSpec") | .spec.secretRef.name' xx00

#rm -rf ./release-image
#oc adm release extract quay.io/openshift-release-dev/ocp-release:4.5.14-x86_64 --to ./release-image

# Find the files with the AWS Provider Spec in them
IAM_FILES=$(find release-image/ -type f -exec grep -l 'AWSProviderSpec' '{}' ';')

for iamfile in ${IAM_FILES}
do

  # Split these files, some contain multiple yaml docs
  csplit -q -f $(basename ${iamfile} '.yaml') "${iamfile}" '/^---/' '{*}'

  SUBFILES=$(ls -1 "$(basename ${iamfile} '.yaml')"*)

  for g in ${SUBFILES}
  do

      if [[ $(yq -r '.spec.providerSpec.kind' ${g}) == 'AWSProviderSpec' ]]
      then

        POLICY_NAME=$(yq -r '.metadata.name' "${g}")

        PERMS=$(yq -r '.spec.providerSpec.statementEntries[].action[]' "${g}")

        # TODO: Change the statement ID to a random number or remove
        cat << EOF > "./${POLICY_NAME}_policy.json"
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1602554784403",
      "Action": [
EOF

        for p in ${PERMS}
        do
          echo "\"${p}\"," >> "./${POLICY_NAME}_policy.json"
        done

        sed -i '$ s/.$//' "./${POLICY_NAME}_policy.json"

        cat << EOF >> "./${POLICY_NAME}_policy.json"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

        jq '.' "./${POLICY_NAME}_policy.json" > t
        mv t "./${POLICY_NAME}_policy.json"

      fi

  done

  rm -f ${SUBFILES}

done

exit 0
