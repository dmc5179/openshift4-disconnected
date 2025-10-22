# Deploying the AWS EFS CSI Driver Operator on OpenShift

- Create the EFS file system with an option KMS key

```console
aws efs create-file-system --encrypted --kms-key-id arn:aws:kms:region:account-id:key/your-kms-key-id --performance-mode generalPurpose --throughput-mode bursting
```
