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

### API Custom SSL Certificate

Create a new secret composed of the crt and the key within OpenShift.

```
oc create secret tls api-cert --cert=<path-to-crt> --key=<path-to-key> -n openshift-config
```

The next step is to update apiserver object to reference the SSL secret and add the hostname

```
oc patch apiserver cluster --type=merge -p '{"spec":{"servingCerts": {"namedCertificates":[{"names": ["api.<cluster-name>.<base-domain>"], "servingCertificate": {"name": "api-cert"}}]}}}'
```

### Ingres Custom SSL Certificate

Create a new secret composed of the crt and the key within OpenShift.

```
oc create secret tls apps-cert --cert=<path-to-crt> --key=<path-to-crt> -n openshift-ingress
```

The next step is to update the default ingress controller operator to reference the SSL secret

```
oc patch ingresscontroller.operator default  --type=merge -p  '{"spec":{"defaultCertificate": {"name": "apps-cert"}}}'  -n openshift-ingress-operator
```


