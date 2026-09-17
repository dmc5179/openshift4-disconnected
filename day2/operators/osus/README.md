# OSUS disconnected

https://developers.redhat.com/articles/2025/12/03/upgrade-air-gapped-openshift-self-signed-certificates#step_4__add_the_router_ca_to_the_user_ca_bundle

## Deploy Operator
```bash

oc create -f 01_namespace.yaml
oc create -f 02_operator_group.yaml
oc create -f 03_subscription.yaml

```

## Configure CA for private Registry

- Edit update-service-registry-ca.yaml and apply

```bash
oc create -f update-service-registry-ca.yaml
```

## Configure Graph Image

- Edit script and run

```bash
./graph-image-configure.sh
```

## Configure CVO

- Edit script and run

```bash
./cvo-configure.sh
```
