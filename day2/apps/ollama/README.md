# Ollama on OpenShift

## Build ollama container with embedded model

```code
MODEL="gemma3-12b"
podman build --build-arg MODEL=${MODEL} -t quay.io/danclark/ollama:${MODEL} -f Containerfile .
```
# Depolying ollama on OpenShift

- ollama runs as root:

```shell
oc adm policy add-scc-to-user anyuid -z default
```

```shell
OLLAMA_IMAGE=quay.io/danclark/ollama:${MODEL}

oc create -f 01-ollama-namespace.yaml

oc create -f 02-ollama-service.yaml

yq --arg image ${OLLAMA_IMAGE} '.spec.template.spec.containers[0].image = $image' 03-ollama-gpu.yaml | oc create -f -
```


## Pulling AI models using podsman as artifacts

```console
podman artifact pull ai/gpt-oss:20B
podman artifact pull ai/gpt-oss-vllm
```
