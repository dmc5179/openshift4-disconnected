# Converting an existing OpenShift Cluster to dual stack with IPv6

```console
oc patch network.config.openshift.io cluster \
  --type='json' --patch-file <file>.yaml
```
