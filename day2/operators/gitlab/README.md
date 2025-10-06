# Installing and Configuring the Gitlab Certified Operator on OpenShift

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

## Patch OCP ingress controller to ignore gitlab's nginx ingress controller if using nginx ingress

- I have not tested this yet. I use the OCP ingress router for right now. Skip this step unless you want to experiment

```console
oc -n openshift-ingress-operator \
  patch ingresscontroller default \
  --type merge \
  -p '{"spec":{"namespaceSelector":{"matchLabels":{"openshift.io/cluster-monitoring":"true"}}}}'
```

## Create S3 credentials secret

- Currently I'm just using the gitlab minio for object storage. I haven't fully tested using AWS S3 for storage. Skip for now

```console
cat <<EOF >> storage.config
[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
bucket_location = ${AWS_DEFAULT_REGION}
multipart_chunk_size_mb = 128 # default is 15 (MB)
EOF

oc create -n gitlab-system secret generic gitlab-object-storage --from-file=config=storage.config
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

