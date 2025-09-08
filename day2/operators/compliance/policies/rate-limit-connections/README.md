# Rate Limit Connections

- OpenShift has an option to set the rate limit for Routes when creating new Routes. All routes outside the openshift namespaces and the kube namespaces should use the rate-limiting annotations
- The usage of rate limit for Routes provides basic protection against distributed denial-of-service (DDoS) attacks.

- Apply the follow patch to the route in the assocatied namespace.  The example below is for Red Hat Advanced Cluster Security (ACS)

```console
oc patch routes/central-mtls --type='json' --patch='{"metadata":{"annotations":{"haproxy.router.openshift.io/rate-limit-connections":"true"}}}' --type=merge -n rhacs-operator

oc patch routes/central --type='json' --patch='{"metadata":{"annotations":{"haproxy.router.openshift.io/rate-limit-connections":"true"}}}' --type=merge -n rhacs-operator
```

- Get a list of the routes that do not have the haproxy.router.openshift.io/rate-limit-connections: true annotation set

```console
oc get routes --all-namespaces -o json | jq '[.items[] | select(.metadata.namespace | startswith("kube-") or startswith("openshift-") | not) | select(.metadata.annotations["haproxy.router.openshift.io/rate-limit-connections"] == "true" | not) | .metadata.name]'
```
