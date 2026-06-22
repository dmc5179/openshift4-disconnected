# oc-mirror streams

- This is a guide to separating OCP and operator into their own imageset-configs to have more mirroring controll

## Mirroring images from Red Hat to disk

### Example that separates into OCP release, redhat operators, and certified operator`
```console
umask 0022

TOP_DIR=$(pwd)

AUTH_FILE="${HOME}/.docker/config.json" # Update this to point to an auth file that can pull images from Red Hat

OC_MIRROR_CACHE_DIR="${HOME}"    # Location where oc-mirror will cache container images as it pulls them from Red Hat. Default is the user home directory

mkdir openshift/mirror || true
mkdir redhat-operators/mirror || true
mkdir certified-operators/mirror || true

oc-mirror --v2 --authfile "${AUTH_FILE}" --cache-dir "${HOME}" --config "${TOP_DIR}/openshift/imageset-config-openshift-release.yaml" "file://${TOP_DIR}/openshift/mirror"

oc-mirror --v2 --authfile "${AUTH_FILE}" --cache-dir "${HOME}" --config "${TOP_DIR}/redhat-operators/imageset-config-redhat-operator-index.yaml" "file://${TOP_DIR}/redhat-operators/mirror"

oc-mirror --v2 --authfile "${AUTH_FILE}" --cache-dir "${HOME}" --config "${TOP_DIR}/certified-operators/imageset-config-certified-operator-index.yaml" "file://${TOP_DIR}/certified-operators/mirror"
```

### Example for a single operator

```console

umask 0022

TOP_DIR=$(pwd)

mkdir -p operators/rhacs/mirror || true

oc-mirror --v2 --authfile "${AUTH_FILE}" --cache-dir "${HOME}" --config "${TOP_DIR}/operators/rhacs/imageset-config-rhacs.yaml" "file://${TOP_DIR}/operators/rhacs/mirror"
```

## Mirroring images from disk to private container registry

- Note: The tar archive file names will not have anything that indicates which oc mirror command or stream they came from. Make sure to keep them together with their respective imageset config yaml files

- On the enclave side create a directory structure like that replicates the internet connected side like

```console
mkdir openshift/mirror || true
mkdir redhat-operators/mirror || true
mkdir certified-operators/mirror || true
mkdir -p operators/rhacs/mirror || true
``` 

- Copy each respective imageset config yaml into their respective directories along with their respective tar archive files

- Push the archives to the private registry like

```console

umask 0022

TOP_DIR=$(pwd)

AUTH_FILE="${HOME}/.docker/config.json" # Update this to point to an auth file that can push container images to your private container registry

OC_MIRROR_CACHE_DIR="${HOME}"    # Location where oc-mirror will cache container images as it pulls them from Red Hat. Default is the user home directory

REGISTRY_URI="myregistry.com:8443" # Include only the hostname and port number. Do not include the protocol like docker:// or https://


oc-mirror --v2 --authfile "${AUTH_FILE}" --cache-dir "${HOME}" --config "${TOP_DIR}/openshift/imageset-config-openshift-release.yaml" --from "file://${TOP_DIR}/openshift/mirror" "docker://${REGISTRY_URI}"

oc-mirror --v2 --authfile "${AUTH_FILE}" --cache-dir "${HOME}" --config "${TOP_DIR}/redhat-operators/imageset-config-redhat-operator-index.yaml" --from "file://${TOP_DIR}/redhat-operators/mirror" "docker://${REGISTRY_URI}"

oc-mirror --v2 --authfile "${AUTH_FILE}" --cache-dir "${HOME}" --config "${TOP_DIR}/certified-operators/imageset-config-certified-operator-index.yaml" --from "file://${TOP_DIR}/certified-operators/mirror" "docker://${REGISTRY_URI}"

oc-mirror --v2 --authfile "${AUTH_FILE}" --cache-dir "${HOME}" --config "${TOP_DIR}/operators/rhacs/imageset-config-rhacs.yaml" --from "file://${TOP_DIR}/operators/rhacs/mirror" "docker://${REGISTRY_URI}"

```
