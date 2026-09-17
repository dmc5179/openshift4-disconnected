helm install --wait --generate-name \
    -n gpu-operator --create-namespace \
    nvidia/gpu-operator \
    --version=v25.3.4
    --set driver.nvidiaDriverCRD.enabled=true
￼
By default, Helm configures a default NVIDIA driver custom resource during installation. To prevent configuring the default custom resource, also specify --set driver.nvidiaDriverCRD.deployDefaultCR=false.


