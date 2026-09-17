https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/gpu-operator-kubevirt.html

https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/4.18/latest/rhcos-4.18.27-x86_64-kubevirt.x86_64.ociarchive

- Configure bare metal worker nodes and ingress operator such that ingress never moves to a virtual worker node
#TODO: Update this to only select bare metal worker nodes. This loop assumes there are currently no virtual worker nodes yet
```console
for n in $(oc get nodes --no-headers=true -o custom-columns=NAME:.metadata.name -lnode-role.kubernetes.io/worker=="")
do
  oc label node "${n}" ingress-node=dedicated
done

- Patch the OpenShift ingress operator to only run on nodes with the label ingress-node:dedicated
```console
oc patch -n openshift-ingress-operator ingresscontroller default --type=merge \
-p='{"spec":{"nodePlacement":{"nodeSelector":{"matchLabels":{"ingress-node":"dedicated"}}}}}'
```

- Create a project for the VMs
```console
oc new-project virt-workers
```

- Create a node agent iso for new worker nodes

adm node-image create

- Download worker.ign from cluster
```console
oc extract -n openshift-machine-api secret/worker-user-data-managed --keys=userData --to=- > worker.ign
```

- Create ignition config secret for VM
```console
oc create -n virt-workers secret generic worker-ignition-payload --from-file=userdata=worker.ign
```

- Shold work as a single command but does not
```console
#oc extract -n openshift-machine-api secret/worker-user-data-managed --keys=userData --to=- 2>&1 | oc create -n virt-workers secret generic ignition-payload --from-file=userdata=-
```

- Create VM
Note: the openshift-install binary version should match the running cluster version under "oc version"
```console
CONTAINER_IMAGE=$(openshift-install coreos print-stream-json | jq -c -r '.architectures.x86_64.images.kubevirt."digest-ref"')
DISK=120
NIC_NAME=nic-$(cat /dev/urandom | tr -dc 'a-z' | head -c 12)
LOCAL_NET="default/hostnetwork-localnet"
cat <<END > vm.yaml
---
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  name: my-rhcos
  #annotations:
  labels:
    #app: rhcos-pod-bridge
    kubevirt.io/dynamic-credentials-support: "true"
spec:
  #running: false # Deprecated
  runStrategy: Halted
  dataVolumeTemplates:
  - metadata:
      name: rootdisk-dv
    spec:
      storage:
        resources:
          requests:
            storage: ${DISK}Gi
        storageClassName: ocs-storagecluster-ceph-rbd-virtualization
        accessModes:
        - ReadWriteMany
      source:
        blank: {}
  template:
    spec:
      domain:
        devices:
          disks:
          - name: rhcos-os-disk
            disk:
              bus: virtio
          interfaces:
          - model: virtio
            masquerade: {}
            name: default
          - bridge: {}
            model: virtio
            name: $NIC_NAME
          rng: {}
        resources:
          requests:
            memory: 8192M
      networks:
      - name: default
        pod: {}
      - multus:
          networkName: default/$LOCAL_NET
        name: $NIC_NAME
      terminationGracePeriodSeconds: 180
      volumes:
      - name: rhcos-os-disk
        dataVolume:
          name: rootdisk-dv
END
oc create -n virt-workers -f vm.yaml
```

- VM will then enter the provisioning state
```console
oc wait --timeout=5m --for=jsonpath='{.status.printableStatus}'=Stopped vm/my-rhcos
```

- Get the MAC from the new VM and create the node yaml
```console
RANDOM_DIR=$(mktemp -d)
NEW_MAC=$(oc get -o json vm my-rhcos | jq -c -r '.spec.template.spec.domain.devices.interfaces[] | select(.name != "default") | .macAddress')
cat <<END > "${RANDOM_DIR}/nodes-config.yaml"
hosts:
  - hostname: ab05ru13virtworker1
    interfaces:
      - name: eth0
        macAddress: ${NEW_MAC}
    networkConfig:
      interfaces:
        - name: eth0
          type: ethernet
          state: up
          mac-address: ${NEW_MAC}
          mtu: 9000
          ipv4:
            enabled: true
            address:
              - ip: 10.150.49.151
                prefix-length: 24
            dhcp: false
    dns-resolver:
      config:
        server:
          - 10.100.128.53
          - 10.100.144.53
    routes:
      config:
        - destination: 0.0.0.0/0
          next-hop-address: 10.150.49.1
          next-hop-interface: eth0
          table-id: 254
END
```

- Create node add ISO
```console
oc adm node-image create "--dir=${RANDOM_DIR}"
```

- Get size of ISO file
```console
stat "${RANDOM_DIR}/node.x86_64.iso"
```

- Upload ISO as data source
```console
virtctl image-upload dv my-rhcos --size=<pvc-size>G "--image-path=${RANDOM_DIR}/node.x86_64.iso" --access-mode=ReadWriteOnce --pvc-namespace=virt-workers
```

- Patch VM yaml with new boot data source
```console
oc patch vm my-rhcos --type merge -p '
{
  "spec": {
    "template": {
      "spec": {
        "domain": {
          "devices": {
            "disks": [
              {
                "name": "iso-disk",
                "bootOrder": 1,
                "cdrom": {
                  "bus": "sata"
                }
              },
              {
                "name": "rhcos-os-disk",
                "bootOrder": 2,
                "disk": {
                  "bus": "virtio"
                }
              }
            ]
          }
        },
        "volumes": [
          {
            "name": "iso-disk",
            "persistentVolumeClaim": {
              "claimName": "iso-pvc"
            }
          },
          {
            "name": "main-disk",
            "persistentVolumeClaim": {
              "claimName": "existing-root-pvc"
            }
          }
        ]
      }
    }
  }
}'
```

- OCP Descheduler annotation
Note: This is untested and may not be needed


Scheduling will be the hardest part due to upgrades. Both bare metal and virtual nodes will act as worker nodes. When the bare metal node tries to upgrade and reboot it would try to live migrate the worker node VM which might disrupt the VM. It might be easier to just delete the OCP virtual worker nodes and VMs prior to an upgrade and simply add then back post upgrade....

```console
echo "Updating descheduler annotation: $VM"
oc patch vm "$VM" --type='json' -p="[{'op': 'add', 'path': '/spec/template/metadata/annotations/descheduler.alpha.kubernetes.io~1evict', 'value': '$DESCHEDULER'}]"
```
