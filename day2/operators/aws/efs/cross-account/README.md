# OpenShift configure cross account AWS EFS storage access

- https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/storage/using-container-storage-interface-csi#persistent-storage-csi-efs-cross-account_persistent-storage-csi-aws-efs

## Configure profiles on bastion machine

```console
export AWS_ACCOUNT_A="<ACCOUNT_A_NAME>"
export AWS_ACCOUNT_B="<ACCOUNT_B_NAME>"

aws configure set aws_access_key_id "" --profile "${AWS_ACCOUNT_A}"
aws configure set aws_secret_access_key "" --profile "${AWS_ACCOUNT_A}"
aws configure set region "us-east-1" --profile "${AWS_ACCOUNT_A}"


aws configure set aws_access_key_id "" --profile "${AWS_ACCOUNT_B}"
aws configure set aws_secret_access_key "" --profile "${AWS_ACCOUNT_B}"
aws configure set region "us-east-1" --profile "${AWS_ACCOUNT_B}"
```


## Possible improvements to IAM roles

```
🔒 Resource Scoping Notice: Actions like ec2:Describe* do not support resource-level permissions and must use "Resource": "*". However, for production implementations, we recommend narrowing down the "Resource" fields for iam:PutUserPolicy, iam:PutRolePolicy, and ec2:CreateRoute using explicit path prefixes or naming standards matching your cluster nomenclature ${CLUSTER_NAME}-*.
```

## Create IAM stuff


- IAM in the AWS account with OpenShift

```
# 1. Create the IAM User for execution
aws iam create-user --user-name OpenShift-Deployer-User

# 2. Create the Customer Managed Policy
POLICY_A_ARN=$(aws iam create-policy \
    --policy-name OpenShiftCrossAccountDeploymentPolicy \
    --policy-document file://policy_account_a.json \
    --query 'Policy.Arn' --output text)

# 3. Attach the policy to the deployment user
aws iam attach-user-policy \
    --user-name OpenShift-Deployer-User \
    --policy-arn "${POLICY_A_ARN}"

# 4. Create the API Access Keys
aws iam create-access-key --user-name OpenShift-Deployer-User
```

- IAM in the AWS account with EFS

```
# 1. Create the IAM User for execution
aws iam create-user --user-name EFS-Storage-Deployer-User

# 2. Create the Customer Managed Policy
POLICY_B_ARN=$(aws iam create-policy \
    --policy-name EFSCrossAccountDeploymentPolicy \
    --policy-document file://policy_account_b.json \
    --query 'Policy.Arn' --output text)

# 3. Attach the policy to the deployment user
aws iam attach-user-policy \
    --user-name EFS-Storage-Deployer-User \
    --policy-arn "${POLICY_B_ARN}"

# 4. Create the API Access Keys
aws iam create-access-key --user-name EFS-Storage-Deployer-User
```
