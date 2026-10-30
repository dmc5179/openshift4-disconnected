#

- https://devfile.io/docs/2.3.0/installation-of-in-cluster-offline-devfile-registry

git clone git@github.com:dmc5179/registry.git

USE_PODMAN=true OFFLINE=true bash -x ./.ci/build.sh

# add to oc mirror from above

# stacks

find stacks/ -type f -name devfile.yaml -exec yq '.components[].container.image' '{}' ';'

#!/bin/bash

for s in $(find stacks/ -type f -name devfile.yaml)
do

  echo "Checking stack: $s"
  count=$(yq '.components | length' "${s}")
  i=0
  
  while [ $i -lt $count ]; do

    if yq --argjson val $i '.components[$val] | has("container")' "${s}" && yq --argjson val $i '.components[$val].container | has("image")' "${s}"
    then
      yq --argjson val $i '.components[$val].container.image' "${s}"
    fi
    
    # Increment the counter
    ((i++))
  done

done


# Point Dev Spaces at the offline registry

CheCluster fields noted while setting this up (see `devspaces-existing.yaml`).
Some are older CheCluster v1 names, so check the current schema with
`oc explain checluster.spec.components.devfileRegistry` and
`oc explain checluster.spec.components.pluginRegistry`:

- `disableInternalRegistry`
- `externalDevfileRegistries`
- `devfileRegistryImage` / `externalDevfileRegistry` (v1)
- `server.externalPluginRegistry` (v1)
