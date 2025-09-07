# Allowed registries for import are configured

-  The configuration allowedRegistriesForImport limits the container image registries from which normal users may import images. This is important to control, as a user who can stand up a malicious registry can then import content which claims to include the SHAs of legitimate content layers. You can set the allowed repositories for import by applying the following manifest using

```console
  oc patch image.config.openshift.io cluster --patch="$(cat ./default-allowed-import-registries-patch.yaml)" --type=merge
```

- id: xccdf_org.ssgproject.content_rule_ocp_allowed_registries_for_import
