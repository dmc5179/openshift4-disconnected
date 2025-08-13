#!/bin/bash -xe
# This script generates the IAM policy documents
# They can be used to create the IAM policies
# No calls to create the policies exist in this script

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Make sure yq and jq are installed. These will fail if they are not
which yq
which jq

rm -rf ./release-image
mkdir ./release-image

OCP_RELEASE=4.19.7
PULL_SECRET=/home/danclark/pull-secret
REPO="quay.io/openshift-release-dev/ocp-release:${OCP_RELEASE}-x86_64"

# This command pulls all the manifests from a release which we don't need for this script
#oc adm release extract --registry-config=${PULL_SECRET} ${REPO} --to ./release-image

oc adm release extract --credentials-requests --cloud=aws --registry-config=${PULL_SECRET} ${REPO} --to ./release-image

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
