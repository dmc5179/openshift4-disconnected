[9:55 AM]apiVersion: che.eclipse.org/v1alpha1
kind: KubernetesImagePuller
metadata:
  name: image-puller-config
spec:
  configMapName: k8s-image-puller
  images: "python-sdk=quay.io/devfile/python:latest;node-js=quay.io/devfile/nodejs:latest"
  nodeSelector:
    disktype: ssd
