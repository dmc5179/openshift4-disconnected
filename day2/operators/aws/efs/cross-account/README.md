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
