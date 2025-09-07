# Allowed registries are configured

-  The configuration registrySources.allowedRegistries determines the permitted registries that the OpenShift container runtime can access for builds and pods. This configuration setting ensures that all registries other than those specified are blocked. You can set the allowed repositories by applying the following manifest using

```console
  oc patch image.config.openshift.io cluster --patch="$(cat ./default-allowed-registries.yaml)" --type=merge
```

- id: xccdf_org.ssgproject.content_rule_ocp_allowed_registries

