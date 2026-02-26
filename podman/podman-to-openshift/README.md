# Migrating podman containers to OpenShift

## Generate OpenShift deployment yaml from a podman container or podman pod
```console
podman generate kube --service --type deployment --replicas 1 --filename ocp-deployment.yaml <container ID or pod ID>
```

### If the podman container or pod has a podman volume, generate yaml for the volume

Note: This does not actually copy the volume or its data. Only generate yaml
```console
podman kube generate volumeName
```

## Exporting a podman volume into OpenShift storage

### Export podman volume data
```console
podman volume export my_local_volume --output my_volume_data.tar
```

### Create a volume in OpenShift
```console

oc create -f

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: podman-pvc
spec:
  #accessModes:
  #  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  #storageClassName:
```

### Deploy a temporary container with the OCP volume attached
```console
oc run data-loader --image=registry.redhat.io/ubi8/ubi --restart=Never --command -- sleep infinity
oc volume pod/data-loader --add --name=volume-mount --claim-name=podman-pvc --mount-path=/data
```

### Copy the data into the OCP volume
```console
oc rsync my_volume_data.tar data-loader:/data/my_volume_data.tar
```

### Extract the data inside the OCP volume
```console
oc exec data-loader -- tar -xf /data/my_volume_data.tar -C /data
```

### Remove the temporary pod
```console
oc delete pod data-loader
```
