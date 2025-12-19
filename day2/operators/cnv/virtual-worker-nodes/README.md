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

- Download worker.ign from cluster
```console
oc extract -n openshift-machine-api secret/worker-user-data-managed --keys=userData --to=- > worker.ign
```

- Create a project for the VMs
```console
oc new-project virt-workers
```

- Create ignition config secret for VM
```console
oc create -n virt-workers secret generic ignition-payload --from-file=userdata=worker.ign
```

- Shold work as a single command but does not
```console
#oc extract -n openshift-machine-api secret/worker-user-data-managed --keys=userData --to=- 2>&1 | oc create -n virt-workers secret generic ignition-payload --from-file=userdata=-
```

- Create VM
```console
CONTAINER_IMAGE=$(openshift-install coreos print-stream-json | jq -c -r '.architectures.x86_64.images.kubevirt."digest-ref"')
DISK=120
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
  #runStrategy: Always
  dataVolumeTemplates:
  - metadata:
      name: rhcos-os-disk-volume
    spec:
      source:
        registry:
          pullMethod: node
          url: docker://${CONTAINER_IMAGE}
      storageClassName: ocs-storagecluster-ceph-rbd-virtualization
      storage:
        volumeMode: Block
        resources:
          requests:
            storage: ${DISK}Gi
        accessModes:
          - ReadWriteOnce # Change to RWX to enable live migration
  template:
    spec:
      domain:
        devices:
          disks:
          - name: rhcos-os-disk
            disk:
              bus: virtio
          - name: cloudinitdisk
            disk:
              bus: virtio
            name: cloudinitdisk
          rng: {}
        resources:
          requests:
            memory: 8192M
      volumes:
      - name: rhcos-os-disk
        dataVolume:
          name: rhcos-os-disk-volume
      - name: cloudinitdisk
        cloudInitConfigDrive:
          secretRef:
            name: ignition-payload
END
oc create -n virt-workers -f vm.yaml
```

- OCP Descheduler annotation
```console
echo "Updating descheduler annotation: $VM"
oc patch vm "$VM" --type='json' -p="[{'op': 'add', 'path': '/spec/template/metadata/annotations/descheduler.alpha.kubernetes.io~1evict', 'value': '$DESCHEDULER'}]"
```
