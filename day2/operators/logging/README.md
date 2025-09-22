# OpenShift Logging Operator Deployment
Prerequisites

You have administrator permissions.
You installed the OpenShift CLI (oc).
You installed and configured Loki Operator.
You have created the openshift-logging namespace.

## Deployment Yaml
```console
oc create -f 01-operatorgroup.yaml
oc create -f 02-subscription.yaml
oc create -f 03-service-account.yaml
oc create -f 04-role-bindings.yaml
```

## Add permissions. Not needed if using all yaml files
```console
oc adm policy add-cluster-role-to-user logging-collector-logs-writer -z logging-collector -n openshift-logging
oc adm policy add-cluster-role-to-user collect-application-logs -z logging-collector -n openshift-logging
oc adm policy add-cluster-role-to-user collect-infrastructure-logs -z logging-collector -n openshift-logging
oc adm policy add-cluster-role-to-user collect-audit-logs -z logging-collector -n openshift-logging
```

```console
oc create -f 03-cluster-log-forwarder.yaml
```

```console
oc create -f 04-logging-ui-plugin.yaml
```
