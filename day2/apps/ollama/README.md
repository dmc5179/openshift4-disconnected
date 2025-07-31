# Ollama on OpenShift

# Build ollama container with embedded model

```code
./build-ollama-container.sh
```
# Depolying ollama on OpenShift

- ollama runs as root:

```shell
oc adm policy add-scc-to-user anyuid -z default
```

- Update 03-ollama-gpu to reference the ollama container image in your registry
  .spec.template.spec.containers[0].image

```shell
oc create -f 01-ollama-namespace.yaml
oc create -f 02-ollama-service.yaml
oc create -f 03-ollama-gpu.yaml
```
