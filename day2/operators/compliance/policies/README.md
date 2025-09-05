# Policies that we could create to increase compliance

## Deploy the logging stack
  https://docs.redhat.com/en/documentation/red_hat_openshift_logging/6.3/html/installing_logging/installing-logging
    - Loki Operator to manage your log store.
    - Red Hat OpenShift Logging Operator to manage log collection and forwarding.
    - Cluster Observability Operator (COO) to manage visualization.

## Image Stream Set Schedule
- mkdir imagestream-sets-schedule
```console
oc patch imagestream NAME -n NAMESPACE --type merge -p '{"spec":{"tags":[{"name":"TAG_NAME","importPolicy":{"scheduled":true}}]}}'
```

## Allowed Registries
, e.g. if you save the following snippet to

/tmp/allowed-registries-patch.yaml

spec:
 registrySources:
   allowedRegistries:
   - my-trusted-registry.internal.example.com

you would call

oc patch image.config.openshift.io cluster --patch="$(cat /tmp/allowed-registries-patch.yaml)" --type=merge

## ocp-allowed-registries-for-import

, e.g. if you save the following snippet to

/tmp/allowed-import-registries-patch.yaml

spec:
 allowedRegistriesForImport:
 - domainName: my-trusted-registry.internal.example.com
   insecure: false

you would call

oc patch image.config.openshift.io cluster --patch="$(cat /tmp/allowed-import-registries-patch.yaml)" --type=merge

## Route rates routes-rate-limit
- https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/ingress_and_load_balancing/configuring-routes#nw-route-specific-annotations_route-configuration

## Container Security Operator
- https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/security_and_compliance/pod-vulnerability-scan
