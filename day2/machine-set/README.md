#

## Spot instances

helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm upgrade --install aws-node-termination-handler \
  --namespace kube-system \
  --set enableSqsTerminationDraining=false \
  --set heartbeatInterval=1000 \
  --set heartbeatUntil=4500 \
  --set nodeSelector."node-role\\.kubernetes\\.io/worker"="" \
  --set deleteLocalData=true \
  --set awsRegion=${AWS_DEFAULT_REGION} \
  eks/aws-node-termination-handler

## Create machineset Role and Rolebindings
- Create the roles for machineset-admin and node-viewer
```console
oc create -f machineset-admin-cluster-role.yaml

oc create -f node-view-cluster-role.yaml
```

- Update the subjects section for both roles in the machineset-admin-cluster-role-binding.yaml for group/user to grant the roles to 
```console
vim machineset-admin-cluster-role-binding.yaml

subjects:
#- kind: User
#  name: name-of-user
#  apiGroup: rbac.authorization.k8s.io
- kind: Group
  name: name-of-group
  apiGroup: rbac.authorization.k8s.io
```

- Establish the role-binding
```console
oc create -f machineset-admin-cluster-role-binding.yaml
```

