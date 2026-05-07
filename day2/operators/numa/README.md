# Schedueling NUMA Aware Workloads

To deploy high performance workloads with optimal efficiency, use NUMA-aware scheduling. This feature aligns pods with the underlying hardware topology in your OpenShift Container Platform cluster, minimizing latency and maximizing resource utilization.

By using the NUMA Resources Operator, you can schedule high-performance workloads in the same NUMA zone. The Operator deploys a node resources exporting agent that reports on available cluster node NUMA resources, and a secondary scheduler that manages the workloads.

https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/scalability_and_performance/cnf-numa-aware-scheduling#installing-the-numa-resources-operator_numa-aware

https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/scalability_and_performance/cnf-tuning-low-latency-nodes-with-perf-profile#cnf-about-the-profile-creator-tool_cnf-tuning-low-latency-nodes-with-perf-profile

https://access.redhat.com/articles/6994974

## Deploy the NUMA resource Operator

```console
oc create -f nro-namespace.yaml

sleep 1

oc create -f nro-operatorgroup.yaml

sleep 2

oc create -f nro-sub.yamlp

sleep 3

oc create -f nro-nro.yaml

sleep 15

oc create -f nro-rs.yaml

sleep 15
```

## Generate a must gather report
```console
mkdir must-gather | true
oc adm must-gather --dest-dir=${PWD}/must-gather/
```

## Compress the must gather report
```console
tar caf must-gather.tar.gz ${PWD}/must-gather/
```

## Run the wrapper script help command
```console
./run-perf-profile-creator.sh -h
```

## Display information about the cluster
```console
./run-perf-profile-creator.sh -t ./must-gather.tar.gz info
```

## Create performance profile
```console
./run-perf-profile-creator.sh -t ./must-gather.tar.gz -- --mcp-name=worker --topology-manager-policy best-effort --reserved-cpu-count=2 --rt-kernel=true --split-reserved-cpus-across-numa=false --power-consumption-mode=ultra-low-latency --offlined-cpu-count=1 > my-performance-profile.yaml
```

## Apply Performance Profile
```console
oc apply -f my-performance-profile.yaml
```


## TODO: Check that the kublet is getting some of these configs from the performance profile process.

- Need to check that the kubelet has some of these fields
```
apiVersion: machineconfiguration.openshift.io/v1
kind: KubeletConfig
metadata:
  name: cpumanager-enabled
spec:
  machineConfigPoolSelector:
    matchLabels:
    custom-kubelet: cpumanager-enabled
  kubeletConfig:
    cpuManagerPolicy: static
    cpuManagerReconcilePeriod: 5s
    reservedSystemCPUs: "0,1"
```

## Example OCP VM config for single NUMA node

```
  cpu:
    cores: 24
    sockets: 4
    threads: 1
    dedicatedCpuPlacement: true
    isolateEmulatorThread: true
    numa:
      guestMappingPassthrough : {}
```

## Do we need to use the topo aware scheduler in the virt deployment like this
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: numa-deployment-1
  namespace: openshift-numaresources
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test
  template:
    metadata:
      labels:
        app: test
    spec:
      schedulerName: topo-aware-scheduler
      containers:
      - name: ctnr
        image: quay.io/openshifttest/hello-openshift:openshift
        imagePullPolicy: IfNotPresent
```

## Benchmarking

### Viewing the numa config on the physical server
- Install numactl package

```console
dnf install numactl
```

- View NUMA layout on the physical server
```console
numactl --hardware   # Node 0 == Disabled. If you see Node 0 and Node 1 that usually means enabled
```

- View CPU to NUMA Node mapping on the physical server
```console
lscpu | grep -i numa
```

- The most dramatic difference between a single-node schedule and a "split" schedule is memory access speed. Use Intel Memory Latency Checker (MLC) or PCM. If you want a native RHEL tool, use numademo

- Run a memory bandwidth test across nodes
```console
numademo -e 128M
```

Look at the "Local" vs "Remote" memory throughput. If single NUMA scheduling is enabled, your throughput should be consistently high because "Remote" hits shouldn't happen.

### Inside the Virtual Machine testing

- CPU Execution time
```console
sysbench cpu --cpu-max-prime=20000 --threads=$(nproc) run
```

- Memory Throughput
```console
sysbench memory --memory-block-size=1M --memory-total-size=10G --threads=$(nproc) run
```

Watch the Operations per second (ops/sec) and Average Latency. When the VM is stretched across NUMA nodes (scheduling disabled), latency spikes because memory requests have to cross the QPI/UPI link between sockets.


#####################################

oc project <namespace with the vm>
oc get vm


oc debug node
chroot /host
crictl ps --namespace cluster-vms
crictl inspect --output go-template --template '{{.info.pid}}' <container ID from the last command>
nsenter -a -t <pid from the last command>




sudo podman run -it --privileged --ipc=host --pid=host --net=host --cap-add=all -v /sys:/sys -v /proc:/proc -v /dev:/dev centos:stream9 bash
ps -eaf | grep qemu-kvm   | grep 'guest=<namespace>_<vm name in ocp>
watch -n 1 numastat -c <pid of qemu-kvm>



## Automation

- get the node

VM_NAME=test-syslog-server
NAMESPACE="cluster-vms"
POD=$(oc get pods -n ${NAMESPACE} -o custom-columns=":metadata.name" --no-headers | grep "${VM_NAME}")
HOST_IP=$(oc get -o jsonpath='{.status.hostIP}' pod ${POD})
NODE=$(oc get -o wide nodes | grep ${HOST_IP} | awk '{print $1}')

PID=$(oc debug node/${NODE} -q -- chroot /host ps -eaf | grep "guest=cluster-vms_test-syslog-server" | awk '{print $2}')

yq --arg node "${NODE}" '.spec.nodeName = $node' toolbox-pod.yaml | oc create -f -

oc wait --for=condition=ready pod/host-debug-pod --timeout=60s

oc exec -it host-debug-pod -- dnf install -y numactl procps-ng

oc exec -it host-debug-pod -- watch -n 1 numastat -c ${PID}
