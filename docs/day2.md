# OpenShift 4 Day 2 Operations

**Table of Contents**
  - [Purpose](#Purpose)


### Purpose

This doc contains steps to perform simple actions in OpenShift 4

#### Disable Master Scheduling
```
oc patch --type=merge --patch='{"spec":{"mastersSchedulable": false}}' schedulers.config.openshift.io cluster
```

### Disable OperatorHub
```
oc patch OperatorHub cluster --type json -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'
```

### Disable Telemetry
```
oc extract secret/pull-secret -n openshift-config --to=.

jq 'del(.auths["cloud.openshift.com"])' .dockerconfigjson > .dockerconfigjson.tmp
mv .dockerconfigjson.tmp .dockerconfigjson

oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=.dockerconfigjson

rm -f .dockerconfigjson
```

### Configure Ingress Replicas

This example sets the replicas to 2, which is the default

```
oc patch -n openshift-ingress-operator ingresscontroller/default --patch "{\"spec\":{\"replicas\": 2}}" --type=merge
```

### Registry EmptyDir

Configure the registry to use the empty dir. Useful for UPI installs that don't have a storage class yet
```
oc patch configs.imageregistry.operator.openshift.io cluster --type merge --patch '{"spec":{"storage":{"emptyDir":{}}}}'
```

### Sample Operator Patch

Patch the samples operator to reference your private registry

```
oc patch configs.samples.operator.openshift.io cluster --type merge \
  --patch "{\"spec\":{\"samplesRegistry\": \"${REMOTE_REG}\", \"managementState\": \"Managed\"}}"
```

