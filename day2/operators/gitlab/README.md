# Installing and Configuring the Gitlab Certified Operator on OpenShift

## Create KMS backed encrypted EBS storage class if needed
- Update the file encrypted-aws-sc.yaml with your AWS KMS ARN
```console
oc create -f encrypted-aws-sc.yaml
```

## Deploy the Operator
```console
oc create -f 01-gitlab-system-namespace.yaml
oc create -f 02-gitlab-operator-group.yaml
oc create -f 03-gitlab-subscription.yaml
```

## Check that the operator is running
```console
oc -n gitlab-system get deployment gitlab-controller-manager
```

## Create S3 buckets

- Precreating the S3 buckets allows for the setting of SSE-KMS

```console
PREFIX=ocp-abc123
aws s3api create-bucket --region us-east-2 --bucket ${PREFIX}-gitlab-artifacts-storage --create-bucket-configuration LocationConstraint=us-east-2
aws s3api create-bucket --region us-east-2 --bucket ${PREFIX}-gitlab-backup-storage --create-bucket-configuration LocationConstraint=us-east-2
aws s3api create-bucket --region us-east-2 --bucket ${PREFIX}-gitlab-tmp-storage --create-bucket-configuration LocationConstraint=us-east-2
aws s3api create-bucket --region us-east-2 --bucket ${PREFIX}-gitlab-ci-secure-files-storage  --create-bucket-configuration LocationConstraint=us-east-2
aws s3api create-bucket --region us-east-2 --bucket ${PREFIX}-gitlab-dependency-proxy --create-bucket-configuration LocationConstraint=us-east-2
aws s3api create-bucket --region us-east-2 --bucket ${PREFIX}-gitlab-external-diffs --create-bucket-configuration LocationConstraint=us-east-2
aws s3api create-bucket --region us-east-2 --bucket ${PREFIX}-gitlab-lfs-storage --create-bucket-configuration LocationConstraint=us-east-2
aws s3api create-bucket --region us-east-2 --bucket ${PREFIX}-gitlab-packages-storage --create-bucket-configuration LocationConstraint=us-east-2
aws s3api create-bucket --region us-east-2 --bucket ${PREFIX}-gitlab-terraform-state-storage --create-bucket-configuration LocationConstraint=us-east-2
aws s3api create-bucket --region us-east-2 --bucket ${PREFIX}-gitlab-uploads-storage --create-bucket-configuration LocationConstraint=us-east-2
aws s3api create-bucket --region us-east-2 --bucket ${PREFIX}-gitlab-pages-storage --create-bucket-configuration LocationConstraint=us-east-2
aws s3api create-bucket --region us-east-2 --bucket ${PREFIX}-gitlab-registry-storage --create-bucket-configuration LocationConstraint=us-east-2
```

- Set SSE-KMS
```console
KMS_ARN="arn"
PREFIX=ocp-abc123
aws s3api put-bucket-encryption --bucket ${PREFIX}-gitlab-artifacts-storage \
              --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"aws:kms","KMSMasterKeyID":"${KMS_ARN}"},"BucketKeyEnabled":true}]}'

aws s3api put-bucket-encryption --bucket ${PREFIX}-gitlab-backup-storage \
              --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"aws:kms","KMSMasterKeyID":"${KMS_ARN}"},"BucketKeyEnabled":true}]}'

aws s3api put-bucket-encryption --bucket ${PREFIX}-gitlab-tmp-storage \
              --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"aws:kms","KMSMasterKeyID":"${KMS_ARN}"},"BucketKeyEnabled":true}]}'

aws s3api put-bucket-encryption --bucket ${PREFIX}-gitlab-ci-secure-files-storage\
              --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"aws:kms","KMSMasterKeyID":"${KMS_ARN}"},"BucketKeyEnabled":true}]}'

aws s3api put-bucket-encryption --bucket ${PREFIX}-gitlab-dependency-proxy\
              --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"aws:kms","KMSMasterKeyID":"${KMS_ARN}"},"BucketKeyEnabled":true}]}'

aws s3api put-bucket-encryption --bucket ${PREFIX}-gitlab-external-diffs\
              --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"aws:kms","KMSMasterKeyID":"${KMS_ARN}"},"BucketKeyEnabled":true}]}'

aws s3api put-bucket-encryption --bucket ${PREFIX}-gitlab-lfs-storage\
              --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"aws:kms","KMSMasterKeyID":"${KMS_ARN}"},"BucketKeyEnabled":true}]}'

aws s3api put-bucket-encryption --bucket ${PREFIX}-gitlab-packages-storage\
              --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"aws:kms","KMSMasterKeyID":"${KMS_ARN}"},"BucketKeyEnabled":true}]}'

aws s3api put-bucket-encryption --bucket ${PREFIX}-gitlab-terraform-state-storage\
              --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"aws:kms","KMSMasterKeyID":"${KMS_ARN}"},"BucketKeyEnabled":true}]}'

aws s3api put-bucket-encryption --bucket ${PREFIX}-gitlab-uploads-storage\
              --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"aws:kms","KMSMasterKeyID":"${KMS_ARN}"},"BucketKeyEnabled":true}]}'

aws s3api put-bucket-encryption --bucket ${PREFIX}-gitlab-pages-storage\
              --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"aws:kms","KMSMasterKeyID":"${KMS_ARN}"},"BucketKeyEnabled":true}]}'

aws s3api put-bucket-encryption --bucket ${PREFIX}-gitlab-registry-storage\
              --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"aws:kms","KMSMasterKeyID":"${KMS_ARN}"},"BucketKeyEnabled":true}]}'
```

## Configure gitlab to use default OpenShift Router certificates

- Export default router cert and key
```console
oc get -o yaml secrets router-certs-default | yq '.data."tls.crt"' | base64 -d > ocp-default-router-tls.crt
oc get -o yaml secrets router-certs-default | yq '.data."tls.key"' | base64 -d > ocp-default-router-tls.key
```

- Create secret with default router cert and key
```console
oc create -n gitlab-system secret tls gitlab-wildcard-tls-certs --cert=ocp-default-router-tls.crt --key=ocp-default-router-tls.key
```


## Create S3 credentials secret

- Update s3cmd-storage.config registry-storage.config gitlab-s3-secrets.yaml with your credentials

```console
oc create -n gitlab-system secret generic gitlab-object-storage --from-file=config=s3cmd-storage.config

oc create -n gitlab-system secret generic registry-storage --from-file=config=registry-storage.config

oc create -n gitlab-system secret generic gitlab-s3-secrets --from-file=connection=gitlab-s3-secrets.yaml
```

## Get console route
kubectl get route -n openshift-console console -ojsonpath='{.status.ingress[0].host}'

- it goes into the CR here. If console is  console-openshift-console.apps.ecs.sandbox1248.opentlc.com
spec:
  chart:
    values:
      global:
        # Configure the domain from the previous step.
        hosts:
          domain: apps.ecs.sandbox1248.opentlc.com


## Create the gitlab CR
```console
oc create -f mygitlab-cr.yaml
```

## POST INSTALL

- Get default credentials. Default user name is 'root'
```console
oc -n gitlab-system get secrets gitlab-gitlab-initial-root-password -o yaml | yq e '.data.password' - | base64 -d
```

- Get the Load Balancer IP
```console
oc get svc -n gitlab-system gitlab-nginx-ingress-controller -ojsonpath='{.status.loadBalancer.ingress[].ip}'
``` console

- Below this is just notes for me

# S3 Storage (Not sure whre this is used yet)
Need to create a secret  registry-storage.yaml 
s3:
  bucket: gitlab-registry-storage
  accesskey: AWS_ACCESS_KEY
  secretkey: AWS_SECRET_KEY
  region: us-east-1
  # regionendpoint: "https://minio.example.com:9000"
  v4auth: true



## Patch OCP ingress controller to ignore gitlab's nginx ingress controller if using nginx ingress

- Not required when using OpenShift Ingress Router
- I have not tested this yet. I use the OCP ingress router for right now. Skip this step unless you want to experiment

```console
oc -n openshift-ingress-operator \
  patch ingresscontroller default \
  --type merge \
  -p '{"spec":{"namespaceSelector":{"matchLabels":{"openshift.io/cluster-monitoring":"true"}}}}'
```
