# Insecure registries

```console
oc edit image.config.openshift.io/cluster
```

```
spec:
  registrySources:
    allowedRegistries             # 
    - registry.redhat.io          # Need this even for disconnected clusters
    - quay.io                     # Need this even for disconnected clusters
    - cloud.openshift.com         # Need this even for disconnected clusters
    - registry.connect.redhat.com # Need this even for disconnected clusters
    - insecure_registry:port      # Append the insecure registry to this list. Don't remove any other entries in this list
    insecureRegistries:           # Add these lines. If insecureRegistries already exist, append the new one to this list. Don't remove any entries.
    - insecure_registry:port      # 
    #allowedRegistriesForImport:  # Only add this section if it already exists as it will have restrictive effects on all other registries
    #- insecure_registry:port
```
