# Configure CPU Manager

- Docs reference
https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html-single/scalability_and_performance/index#setting_up_cpu_manager_using-cpu-manager-and-topology-manager

## Label nodes where cpu manager will be enabled and configured
```console
oc label node <node-name> cpumanager=true
```

## Patch machine config pool to use the custom kubelet config
```conosole
oc patch machineconfigpool worker --type=merge -p '{"metadata":{"labels":{"custom-kubelet":"cpumanager-enabled"}}}'
```

## Create custom kubelet config
```console
oc create -f cpumanager-kubeletconfig.yaml
```

## Deploy pods to cpu manager enabled nodes
```
  nodeSelector:
    cpumanager: "true"
```

## Verify that a CPU has been exclusively assigned to the pod by running the following command
```console
oc describe node --selector='cpumanager=true' | grep -i cpumanager- -B2
```
