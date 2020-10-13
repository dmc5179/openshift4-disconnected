#!/bin/bash -xe

POLICY_FILE='openshift_policy.json'

rm -rf ./release-image
oc adm release extract quay.io/openshift-release-dev/ocp-release:4.5.14-x86_64 --to ./release-image

IAM_FILES=$(find release-image/ -type f -exec grep -l 'AWSProviderSpec' '{}' ';')

PERMS=$(for f in ${IAM_FILES}
do
  awk '/action:/{flag=1; next} /resource:/{flag=0} flag' "$f" | tr -d ' ' | tr -d '-'
done)

cat << EOF > ./${POLICY_FILE}
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1602554784403",
      "Action": [
EOF

for p in ${PERMS}
do

  echo "\"${p}\"," >> ./${POLICY_FILE}

done

sed -i '$ s/.$//' ${POLICY_FILE}

cat << EOF >> ./${POLICY_FILE}
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

jq '.' ${POLICY_FILE} > t
mv t ${POLICY_FILE}

aws iam create-policy --policy-name openshift --policy-document "file://${PWD}/${POLICY_FILE}"
