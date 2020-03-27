# Nvidia GPU Operator

To install this operator in a disconnected environment there are several configuration changes that need to be made

- Download the gpu-operator helm chart
- Download the helm binary
- Download the helm repository index.yaml
- Modify the gpu-operator helm chart from Nvidia to support a disconnected installation
- Repackage the modified operator
- Update the index.yaml with the digest of the modified helm chart
- Stage the index.yaml and modified helm chart in a web server


