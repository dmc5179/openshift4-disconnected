# Deploying an OCP cluster with the ClusterInstance CR

- Follow this guide
https://access.redhat.com/articles/7079633

## Enable the SiteConfig Operator

```console
bash setup/enable-siteconfig-operator.sh
oc create -f setup/01-agent-servce-config.yaml
oc create -f setup/02-metal3-provisioning.yaml
```

## Configure permissions for RHACM
```console
oc adm policy add-cluster-role-to-user --rolebinding-name=open-cluster-management:subscription-admin open-cluster-management:subscription-admin kube:admin

oc adm policy add-cluster-role-to-user --rolebinding-name=open-cluster-management:subscription-admin open-cluster-management:subscription-admin system:admin
```

## Deploying the cluster

- Create a namespace for the cluster
```console
oc create -f sno1/00-namespace.yaml
```

- Create a secret with credentials for the BMC of the SNO system
```console
oc create -f 01-bmc-secret.yaml
```

- Create a BareMetalHost object representing the SNO system
```console
oc create -f 01-bmh.yaml
```

- Create a pull secret for the SNO cluster to pull containers
```console
oc create secret generic -n sno1 sno1 --from-file=.dockerconfigjson=/home/danclark/pull-secret --type=kubernetes.io/dockerconfigjson
```

- Deploy the new SNO cluster
```console
oc create -f sno1/ClusterInstance-sno1.yaml
```

# Commands to inspect the objects created by the ClusterInstance to check the status
```console
oc describe ClusterInstance sno1
oc describe bmh ab05ru15
oc describe managedcluster sno1
oc describe clusterdeployment sno1
oc describe AgentClusterInstall sno1
oc describe InfraEnv sno1
oc describe clusterdeployment sno1
oc describe bmh ab05ru07
```
