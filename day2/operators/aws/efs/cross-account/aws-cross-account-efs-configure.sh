#!/bin/bash

# AWS Account A: Contains a Red Hat OpenShift Container Platform cluster v4.16, or later, deployed within a VPC
# AWS Account B: Contains a VPC (including subnets, route tables, and network connectivity). The EFS filesystem will be created in this VPC.
#
# NOTE: Account A contains OpenShift. Account B contains the EFS storage we want to access from OCP in account A

# Configure both account variables
export CLUSTER_NAME="<CLUSTER_NAME>" 
export AWS_REGION="<AWS_REGION>" 
export AWS_ACCOUNT_A_ID="<ACCOUNT_A_ID>" 
export AWS_ACCOUNT_B_ID="<ACCOUNT_B_ID>" 
export AWS_ACCOUNT_A_VPC_CIDR="<VPC_A_CIDR>" 
export AWS_ACCOUNT_B_VPC_CIDR="<VPC_B_CIDR>" 
export AWS_ACCOUNT_A_VPC_ID="<VPC_A_ID>" 
export AWS_ACCOUNT_B_VPC_ID="<VPC_B_ID>" 
export SCRATCH_DIR="<WORKING_DIRECTORY>" 
export CSI_DRIVER_NAMESPACE="openshift-cluster-csi-drivers" 
export AWS_PAGER="" 

# Uncomment and set this if there is already an EFS storage system in account B
#export CROSS_ACCOUNT_FS_ID=""

# Configure profiles
export AWS_ACCOUNT_A="<ACCOUNT_A_NAME>"
export AWS_ACCOUNT_B="<ACCOUNT_B_NAME>"

# Tests
export AWS_DEFAULT_PROFILE=${AWS_ACCOUNT_A}
aws configure get output
export AWS_DEFAULT_PROFILE=${AWS_ACCOUNT_B}
aws configure get output


# Configure node selector
export NODE_SELECTOR=node-role.kubernetes.io/worker

# Unset AWS profiles
unset AWS_PROFILE


# AWS Account B (EFS Account) Configure

export AWS_DEFAULT_PROFILE=${AWS_ACCOUNT_B}

export ACCOUNT_B_ROLE_NAME=${CLUSTER_NAME}-cross-account-aws-efs-csi-operator

cat <<EOF > $SCRATCH_DIR/AssumeRolePolicyInAccountB.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${AWS_ACCOUNT_A_ID}:root"
            },
            "Action": "sts:AssumeRole",
            "Condition": {}
        }
    ]
}
EOF

ACCOUNT_B_ROLE_ARN=$(aws iam create-role \
  --role-name "${ACCOUNT_B_ROLE_NAME}" \
  --assume-role-policy-document file://$SCRATCH_DIR/AssumeRolePolicyInAccountB.json \
  --query "Role.Arn" --output text) \
&& echo $ACCOUNT_B_ROLE_ARN

cat << EOF > $SCRATCH_DIR/EfsPolicyInAccountB.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeSubnets"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "elasticfilesystem:DescribeMountTargets",
                "elasticfilesystem:DeleteAccessPoint",
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:DescribeAccessPoints",
                "elasticfilesystem:ClientWrite",
                "elasticfilesystem:ClientRootAccess",
                "elasticfilesystem:DescribeFileSystems",
                "elasticfilesystem:CreateAccessPoint",
                "elasticfilesystem:TagResource"
            ],
            "Resource": "*"
        }
    ]
}
EOF

ACCOUNT_B_POLICY_ARN=$(aws iam create-policy --policy-name "${CLUSTER_NAME}-efs-csi-policy" \
   --policy-document file://$SCRATCH_DIR/EfsPolicyInAccountB.json \
   --query 'Policy.Arn' --output text) \
&& echo ${ACCOUNT_B_POLICY_ARN}

aws iam attach-role-policy \
   --role-name "${ACCOUNT_B_ROLE_NAME}" \
   --policy-arn "${ACCOUNT_B_POLICY_ARN}"


# AWS Account A Configure

export AWS_DEFAULT_PROFILE=${AWS_ACCOUNT_A}

cat << EOF > $SCRATCH_DIR/AssumeRoleInlinePolicyPolicyInAccountA.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "${ACCOUNT_B_ROLE_ARN}"
    }
  ]
}
EOF

EFS_CLIENT_FULL_ACCESS_BUILTIN_POLICY_ARN=arn:aws:iam::aws:policy/AmazonElasticFileSystemClientFullAccess
declare -A ROLE_SEEN
for NODE in $(oc get nodes --selector="${NODE_SELECTOR}" -o jsonpath='{.items[*].metadata.name}'); do
    INSTANCE_PROFILE=$(aws ec2 describe-instances \
        --filters "Name=private-dns-name,Values=${NODE}" \
        --query 'Reservations[].Instances[].IamInstanceProfile.Arn' \
        --output text | awk -F'/' '{print $NF}' | xargs)
    MASTER_ROLE_ARN=$(aws iam get-instance-profile \
        --instance-profile-name "${INSTANCE_PROFILE}" \
        --query 'InstanceProfile.Roles[0].Arn' \
        --output text | xargs)
    MASTER_ROLE_NAME=$(echo "${MASTER_ROLE_ARN}" | awk -F'/' '{print $NF}' | xargs)
    echo "Checking role: '${MASTER_ROLE_NAME}'"
    if [[ -n "${ROLE_SEEN[$MASTER_ROLE_NAME]:-}" ]]; then
        echo "Already processed role: '${MASTER_ROLE_NAME}', skipping."
        continue
    fi
    ROLE_SEEN["$MASTER_ROLE_NAME"]=1
    echo "Assigning policy ${EFS_CLIENT_FULL_ACCESS_BUILTIN_POLICY_ARN} to role ${MASTER_ROLE_NAME}"
    aws iam attach-role-policy --role-name "${MASTER_ROLE_NAME}" --policy-arn "${EEFS_CLIENT_FULL_ACCESS_BUILTIN_POLICY_ARN}"
done

# CHOICES! Unclear if we do both of these when non-sts mode. Docs update?

# NON-STS Mode
EFS_CSI_DRIVER_OPERATOR_USER=$(oc -n openshift-cloud-credential-operator get credentialsrequest/openshift-aws-efs-csi-driver -o json | jq -r '.status.providerStatus.user')

aws iam put-user-policy \
    --user-name "${EFS_CSI_DRIVER_OPERATOR_USER}"  \
    --policy-name efs-cross-account-inline-policy \
    --policy-document file://$SCRATCH_DIR/AssumeRoleInlinePolicyPolicyInAccountA.json

# STS-Mode

EFS_CSI_DRIVER_OPERATOR_ROLE=$(oc -n ${CSI_DRIVER_NAMESPACE} get secret/aws-efs-cloud-credentials -o jsonpath='{.data.credentials}' | base64 -d | grep role_arn | cut -d'/' -f2) && echo ${EFS_CSI_DRIVER_OPERATOR_ROLE}

aws iam put-role-policy \
   --role-name "${EFS_CSI_DRIVER_OPERATOR_ROLE}"  \
   --policy-name efs-cross-account-inline-policy \
   --policy-document file://$SCRATCH_DIR/AssumeRoleInlinePolicyPolicyInAccountA.json


# VPC Peering

export AWS_DEFAULT_PROFILE=${AWS_ACCOUNT_A}
PEER_REQUEST_ID=$(aws ec2 create-vpc-peering-connection --vpc-id "${AWS_ACCOUNT_A_VPC_ID}" --peer-vpc-id "${AWS_ACCOUNT_B_VPC_ID}" --peer-owner-id "${AWS_ACCOUNT_B_ID}" --query VpcPeeringConnection.VpcPeeringConnectionId --output text)

export AWS_DEFAULT_PROFILE=${AWS_ACCOUNT_B}
aws ec2 accept-vpc-peering-connection --vpc-peering-connection-id "${PEER_REQUEST_ID}"

export AWS_DEFAULT_PROFILE=${AWS_ACCOUNT_A}
for NODE in $(oc get nodes --selector=node-role.kubernetes.io/worker | tail -n +2 | awk '{print $1}')
do
    SUBNET=$(aws ec2 describe-instances --filters "Name=private-dns-name,Values=$NODE" --query 'Reservations[*].Instances[*].NetworkInterfaces[*].SubnetId' | jq -r '.[0][0][0]')
    echo SUBNET is ${SUBNET}
    ROUTE_TABLE_ID=$(aws ec2 describe-route-tables --filters "Name=association.subnet-id,Values=${SUBNET}" --query 'RouteTables[*].RouteTableId' | jq -r '.[0]')
    echo Route table ID is $ROUTE_TABLE_ID
    aws ec2 create-route --route-table-id ${ROUTE_TABLE_ID} --destination-cidr-block ${AWS_ACCOUNT_B_VPC_CIDR} --vpc-peering-connection-id ${PEER_REQUEST_ID}
done

export AWS_DEFAULT_PROFILE=${AWS_ACCOUNT_B}
for ROUTE_TABLE_ID in $(aws ec2 describe-route-tables   --filters "Name=vpc-id,Values=${AWS_ACCOUNT_B_VPC_ID}"   --query "RouteTables[].RouteTableId" | jq -r '.[]')
do
    echo Route table ID is $ROUTE_TABLE_ID
    aws ec2 create-route --route-table-id ${ROUTE_TABLE_ID} --destination-cidr-block ${AWS_ACCOUNT_A_VPC_CIDR} --vpc-peering-connection-id ${PEER_REQUEST_ID}
done

# Configure Security Groups

export AWS_DEFAULT_PROFILE=${AWS_ACCOUNT_B}

SECURITY_GROUP_ID=$(aws ec2 describe-security-groups --filters Name=vpc-id,Values="${AWS_ACCOUNT_B_VPC_ID}" | jq -r '.SecurityGroups[].GroupId')
aws ec2 authorize-security-group-ingress \
 --group-id "${SECURITY_GROUP_ID}" \
 --protocol tcp \
 --port 2049 \
 --cidr "${AWS_ACCOUNT_A_VPC_CIDR}" | jq .

# Region wide EFS

export AWS_DEFAULT_PROFILE=${AWS_ACCOUNT_B}

# This creates a new EFS file system.....
if [ -z ${CROSS_ACCOUNT_FS_ID} ]
then 
  CROSS_ACCOUNT_FS_ID=$(aws efs create-file-system --creation-token efs-token-1 \
  --region ${AWS_REGION} \
  --encrypted | jq -r '.FileSystemId')
fi
echo "Cross account FS ID: $CROSS_ACCOUNT_FS_ID"

for SUBNET in $(aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=${AWS_ACCOUNT_B_VPC_ID}" \
  --region ${AWS_REGION} \
  | jq -r '.Subnets.[].SubnetId'); do \
    MOUNT_TARGET=$(aws efs create-mount-target --file-system-id ${CROSS_ACCOUNT_FS_ID} \
    --subnet-id ${SUBNET} \
    --region ${AWS_REGION} \
    | jq -r '.MountTargetId'); \
    echo ${MOUNT_TARGET}; \
done

# Configure the EFS Operator for cross-account access

export SECRET_NAME=my-efs-cross-account
export STORAGE_CLASS_NAME=efs-sc-cross

oc create secret generic ${SECRET_NAME} -n ${CSI_DRIVER_NAMESPACE} --from-literal=awsRoleArn="${ACCOUNT_B_ROLE_ARN}"

oc -n ${CSI_DRIVER_NAMESPACE} create role access-secrets --verb=get,list,watch --resource=secrets
oc -n ${CSI_DRIVER_NAMESPACE} create rolebinding --role=access-secrets default-to-secrets --serviceaccount=${CSI_DRIVER_NAMESPACE}:aws-efs-csi-driver-controller-sa

cat << EOF | oc apply -f -
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: ${STORAGE_CLASS_NAME}
provisioner: efs.csi.aws.com
parameters:
  provisioningMode: efs-ap
  fileSystemId: ${CROSS_ACCOUNT_FS_ID}
  directoryPerms: "700"
  gidRangeStart: "1000"
  gidRangeEnd: "2000"
  basePath: "/dynamic_provisioning"
  csi.storage.k8s.io/provisioner-secret-name: ${SECRET_NAME}
  csi.storage.k8s.io/provisioner-secret-namespace: ${CSI_DRIVER_NAMESPACE}
EOF
