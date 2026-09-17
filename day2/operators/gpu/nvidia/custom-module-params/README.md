
kubectl create configmap kernel-module-params -n gpu-operator --from-file=nvidia-uvm.conf=./nvidia-uvm.conf

   --set driver.kernelModuleConfig.name="kernel-module-params"
