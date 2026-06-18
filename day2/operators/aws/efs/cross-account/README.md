# OpenShift configure cross account AWS EFS storage access

- https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/storage/using-container-storage-interface-csi#persistent-storage-csi-efs-cross-account_persistent-storage-csi-aws-efs

## Configure profiles on bastion machine

- Set profile names
```console
export AWS_ACCOUNT_A="<ACCOUNT_A_NAME>"
export AWS_ACCOUNT_B="<ACCOUNT_B_NAME>"
```

### Interactive Mode
```console
aws configure --profile "${AWS_ACCOUNT_A}"
aws configure --profile "${AWS_ACCOUNT_B}"
```

### Non-Interactive Mode
```console

aws configure set aws_access_key_id <AWS Access Key ID> --profile "${AWS_ACCOUNT_A}"
aws configure set aws_secret_access_key <AWS Sec Key> --profile "${AWS_ACCOUNT_A}"
aws configure set region <AWS Region> --profile "${AWS_ACCOUNT_A}"


aws configure set aws_access_key_id <AWS Access Key ID> --profile "${AWS_ACCOUNT_B}"
aws configure set aws_secret_access_key <AWS Sec Key> --profile "${AWS_ACCOUNT_B}"
aws configure set region <AWS Region> --profile "${AWS_ACCOUNT_B}"
```


## Possible improvements to IAM roles

- Need to update to use aws-us-gov for gov cloud ARN

```
🔒 Resource Scoping Notice: Actions like ec2:Describe* do not support resource-level permissions and must use "Resource": "*". However, for production implementations, we recommend narrowing down the "Resource" fields for iam:PutUserPolicy, iam:PutRolePolicy, and ec2:CreateRoute using explicit path prefixes or naming standards matching your cluster nomenclature ${CLUSTER_NAME}-*.
```

## Create IAM stuff

- In running outside of AWS commercial, make sure to change the ARN in the policy json

```console
export ARN="aws-us-gov"
sed -i "s|arn:aws:|arn:${ARN}:|g"  aws-account-a-iam-policy.json

sed -i "s|arn:aws:|arn:${ARN}:|g" aws-account-b-iam-policy.json
```

- IAM in the AWS account with OpenShift

```console
# 1. Create the IAM User for execution
aws iam create-user --user-name OpenShift-Deployer-User

# 2. Create the Customer Managed Policy
POLICY_A_ARN=$(aws iam create-policy \
    --policy-name OpenShiftCrossAccountDeploymentPolicy \
    --policy-document file://aws-account-a-iam-policy.json \
    --query 'Policy.Arn' --output text)

# 3. Attach the policy to the deployment user
aws iam attach-user-policy \
    --user-name OpenShift-Deployer-User \
    --policy-arn "${POLICY_A_ARN}"

# 4. Create the API Access Keys
aws iam create-access-key --user-name OpenShift-Deployer-User
```

- IAM in the AWS account with EFS

```console
# 1. Create the IAM User for execution
aws iam create-user --user-name EFS-Storage-Deployer-User

# 2. Create the Customer Managed Policy
POLICY_B_ARN=$(aws iam create-policy \
    --policy-name EFSCrossAccountDeploymentPolicy \
    --policy-document file://aws-account-b-iam-policy.json \
    --query 'Policy.Arn' --output text)

# 3. Attach the policy to the deployment user
aws iam attach-user-policy \
    --user-name EFS-Storage-Deployer-User \
    --policy-arn "${POLICY_B_ARN}"

# 4. Create the API Access Keys
aws iam create-access-key --user-name EFS-Storage-Deployer-User
```
