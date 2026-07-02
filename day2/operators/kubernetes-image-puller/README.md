# Kubernetes Image Puller Operator

- Currently a community operator

- Useful with RHOAI to pre-pull large contianer images to OCP nodes.

- Be careful about how much space it consumes on the OCP node disks

- Can limit daemonset with a node selector to match only the nodes that have GPUs
