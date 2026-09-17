# Deploying the AWS EFS CSI Driver Operator on OpenShift

The AWS EFS CSI Storage Driver is part of the community operator catalog index

OpenShift documentation for deploying the EFS CSI driver is here:

https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/storage/using-container-storage-interface-csi#persistent-storage-csi-aws-efs

## Create the EFS file system with an option KMS key

- Skip this section if the EFS filesystem already exists
- Remove the kms and encrypted options of not needed

```console
aws efs create-file-system --encrypted --kms-key-id arn:aws:kms:region:account-id:key/your-kms-key-id --performance-mode generalPurpose --throughput-mode bursting
```

## Install the AWS EFS CSI Driver Operator

- Install the operator from the OperatorHub/Ecosystem page in the openshift web UI

## Install Cluster CSI Driver

```console
oc create -f efs-cluster-csi-driver.yaml
```

## Create EFS Storage Class

```console
oc create -f efs-sc.yaml
```

## Deploy a test pod

```console
oc new-project efs-test-deployment
oc project efs-test-deployment
oc create -f efs-test-pod.yaml
```
