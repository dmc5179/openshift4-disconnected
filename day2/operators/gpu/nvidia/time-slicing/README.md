# openshift-cuda-timeslicing
Steps to configure timeslicing CUDA pools on OpenShift

- Scale down all pods that are using GPUs on a node that will be reconfigured. A node cannot be reconfigured while pods are still attached to the GPU devices.

- Create the slicing configuration
```bash
oc create -f time-slicing-config-map.yaml
```

- Patch the GPU operator to load the slicing config but not apply it to any nodes by default
```bash
oc patch clusterpolicy \
   gpu-cluster-policy \
   -n nvidia-gpu-operator \
   --type merge \
   -p '{"spec": {"devicePlugin": {"config": {"name": "time-slicing-config"}}}}'
```

- Confirm pod restarts
```bash
oc get events -n gpu-operator --sort-by='.lastTimestamp'
```


- Find the nodes that you want to label
```bash
oc get nodes
```

- Label one or more nodes to use the slicing config
```bash
oc label \
--overwrite node this-is-your-host-name.example.com \
nvidia.com/device-plugin.config=NVIDIA-DGX1-PCIE-16GB
```

- Describe the node
```bash
oc describe node <node-name>
```

- Look for the number of replicas
```bash
...
Labels:
                  nvidia.com/gpu.count=8
                  nvidia.com/gpu.product=NVIDIA-DGX1-PCIE-16GB
                  nvidia.com/gpu.replicas=2
Capacity:
  nvidia.com/gpu: 16
  ...
Allocatable:
  nvidia.com/gpu: 16
  ...
```

- Scale back up GPU pods
