# Nvidia GPU Operator

To install this operator in a disconnected environment there are several configuration changes that need to be made

## Overall steps in a Disconnected Environment

- Download the gpu-operator helm chart
- Download the helm binary
- Download the helm repository index.yaml
- Modify the gpu-operator helm chart from Nvidia to support a disconnected installation
- Repackage the modified operator
- Update the index.yaml with the digest of the modified helm chart
- Stage the index.yaml and modified helm chart in a web server

### Required Container Images

```
skopeo copy docker-archive:///<path-to-images>/nvidia-gpu-operator/gpu-operator-1.0.0.tar docker://openshift4-registry.redhatgovsa.io:5000/ocp4/gpu-operator:1.0.0

# Driver getting copied to 2 places because the helm chart isn't clear and there is no driver:440.33.01 tag in docker hub
skopeo copy docker-archive://<path-to-images>/nvidia-gpu-operator/driver.440.33.01-rhcos4.3.tar docker://<registry:port>/ocp4/driver:440.33.01
skopeo copy docker-archive://<path-to-images>/nvidia-gpu-operator/driver.440.33.01-rhcos4.3.tar docker://<registry:port>/ocp4/driver:440.33.01-rhcos4.3

skopeo copy docker-archive://<path-to-images>/nvidia-gpu-operator/k8s-device-plugin.1.0.0-beta4.tar docker://<registry:port>/ocp4/k8s-device-plugin:1.0.0-beta4

skopeo copy docker-archive://<path-to-images>/nvidia-gpu-operator/container-toolkit.1.0.0-alpha.3.tar docker://<registry:port>/ocp4/container-toolkit:1.0.0-alpha.3

skopeo copy docker-archive://<path-to-images>/nvidia-gpu-operator/dcgm-exporter.1.0.0-beta-ubuntu18.04.tar docker://<registry:port>/ocp4/dcgm-exporter:1.0.0-beta-ubuntu18.04

skopeo copy docker-archive://<path-to-images>/nvidia-gpu-operator/pod-gpu-metrics-exporter.v1.0.0-alpha.tar docker://<registry:port>/ocp4/pod-gpu-metrics-exporter:v1.0.0-alpha
```

### Create ImageContentSourcePolicy

Map the images to their new names in the disconnected registry

```
oc apply -f nvidia-gpu-operator-1.0.0-icsp.yaml
```

### Download and Modify the helm chart

The helm charts have image references that do not use a registry like docker.io. They simply say 'nvidia/driver:version'
These need to be modified to include docker.io (their actual location) so that OCP's ImageContentSourcePolcies can properly map them
Once the helm chart is downloaded, modified, and repackaged, generate a new SHA256 digest

### Standup Helm Chart

Download the helm chart and index

```
wget https://nvidia.github.io/gpu-operator/index.yaml
```

Modify the helm chart with the digest of the modified operator

### Install with the helm chart: Make sure to use helm v3

```
helm install --devel http://${HELM_HOST}/gpu-operator/gpu-operator-1.0.0.tgz --set platform.openshift=true,operator.defaultRuntime=crio,nfd.enabled=false --wait --generate-name
```
