#!/bin/bash

rm -rf ./release-image
oc adm release extract quay.io/openshift-release-dev/ocp-release:4.5.14-x86_64 --to ./release-image

IAM_FILES=$(find release-image/ -type f -exec grep -l 'AWSProviderSpec' '{}' ';')


for f in ${IAM_FILES}
do

  # TODO: This is not a good way to do this
  # In all of the files now, AWS is the first one but that may not always be true
  POLICY_NAME=$(yq -r '.metadata.name' "${f}" | grep -v null | head -1)

  echo "File: $f   Name: ${POLICY_NAME}"

  PERMS=$(awk '/action:/{flag=1; next} /resource:/{flag=0} flag' "$f" | tr -d ' ' | tr -d '-')

  echo "${PERMS}"

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

done

exit 0
