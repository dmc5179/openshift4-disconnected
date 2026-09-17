# Link Node to Bare Metal Host and Machine Object

- Derived from the following access article

https://access.redhat.com/solutions/7130140#ocp_step_10

## Set Variables needed to link

```console
export NODE_NAME=""          # Node name from "oc get nodes"
export NEW_MACHINE_NAME=""   # Typically same as NODE_NAME
export BOOT_MAC=""           # MAC address of boot NICE
export BOOT_MODE=""          # UEFI vs legacy
export CLUSTER_NAME=$(oc get infrastructure cluster -o=jsonpath='{.status.infrastructureName}{"\n"}')
export ROLE="worker"         # master or worker
```

## Create template files

- Bare Metal Host Template
```console
cat <<EOF > bare-metal-host-object.yaml
apiVersion: metal3.io/v1alpha1
kind: BareMetalHost
metadata:
  name: bmh-name
  namespace: openshift-machine-api
spec:
  automatedCleaningMode: metadata
  bootMACAddress: 00:00:00:00:00:00
  bootMode: legacy
  customDeploy:
    method: install_coreos
  externallyProvisioned: true
  online: true
  userData:
    name: worker-user-data-managed
    namespace: openshift-machine-api
EOF
```

- Machine Template
```console
cat <<EOF > machine-object.yaml
apiVersion: machine.openshift.io/v1beta1
kind: Machine
metadata:
  annotations:
    machine.openshift.io/instance-state: unmanaged
    metal3.io/BareMetalHost: openshift-machine-api/node-name
  finalizers:
    - machine.machine.openshift.io
  labels:
    machine.openshift.io/cluster-api-cluster: cluster-id
    machine.openshift.io/cluster-api-machine-role: worker
    machine.openshift.io/cluster-api-machine-type: worker
  name: node-name
  namespace: openshift-machine-api
spec:
  metadata: {}
  providerSpec:
    value:
      apiVersion: baremetal.cluster.k8s.io/v1alpha1
      customDeploy:
        method: install_coreos
      hostSelector: {}
      image:
        checksum: ''
        url: ''
      kind: BareMetalMachineProviderSpec
      metadata:
        creationTimestamp: null
      userData:
        name: worker-user-data-managed
EOF
```


## Create Bare Metal Host Object

```console

yq -y -i --arg val ${NODE_NAME} '.metadata.name = $val' bare-metal-host-object.yaml

yq -y -i --arg val ${BOOT_MAC} '.spec.bootMACAddress = $val' bare-metal-host-object.yaml

yq -y -i --arg val ${BOOT_MODE} '.spec.bootMode = $val' bare-metal-host-object.yaml

user_data="${ROLE}-user-data-managed"
yq -y -i --arg val ${user_data} '.spec.userData.name = $val' bare-metal-host-object.yaml

oc create -f bare-metal-host-object.yaml
```

## Create Machine Object

```console

bmh="openshift-machine-api/${NODE_NAME}"
yq -y -i --arg val ${bmh} '.metadata.annotations."metal3.io/BareMetalHost" = $val' machine-object.yaml

yq -y -i --arg val ${CLUSTER_NAME} '.metadata.labels."machine.openshift.io/cluster-api-cluster" = $val' machine-object.yaml

yq -y -i --arg val ${ROLE} '.metadata.labels."machine.openshift.io/cluster-api-machine-role" = $val' machine-object.yaml
yq -y -i --arg val ${ROLE} '.metadata.labels."machine.openshift.io/cluster-api-machine-type" = $val' machine-object.yaml

yq -y -i --arg val ${NODE_NAME} '.metadata.name = $val' machine-object.yaml

user_data="${ROLE}-user-data-managed"
yq -y -i --arg val ${user_data} '.spec.providerSpec.value.userData.name = $val' machine-object.yaml

oc create -f machine-object.yaml
```

## Link the Node, Machine, and BareMetalHost

### Define the BMH_UID by using the following command to extract it from the new node’s bmh

```console
export BMH_UID=$(oc get -n openshift-machine-api bmh $NODE_NAME -ojson | jq -r .metadata.uid)
echo $BMH_UID
```

### Patch consumerRef object into baremetal host

```console
oc patch -n openshift-machine-api bmh $NODE_NAME --type merge --patch '{"spec":{"consumerRef":{"apiVersion":"machine.openshift.io/v1beta1","kind":"Machine","name":"'$NEW_MACHINE_NAME'","namespace":"openshift-machine-api"}}}'
```

### Patch providerID into the new node

```console
oc patch node $NODE_NAME --type merge --patch '{"spec":{"providerID":"baremetalhost:///openshift-machine-api/'$NODE_NAME'/'$BMH_UID'"}}'
```

### Review the providerIDs

```console
oc get node -l node-role.kubernetes.io/${ROLE} -ojson | jq -r '.items[] | .metadata.name + "  " + .spec.providerID'
```

### Set bmh poweredOn (if necessary)

```
oc patch -n openshift-machine-api bmh $NODE_NAME --subresource status --type json -p '[{"op":"replace","path":"/status/poweredOn","value":true}]'
```

### Review bmh poweredOn status

```
oc get bmh -n openshift-machine-api -ojson | jq -r '.items[] | .metadata.name + "   PoweredOn:" +  (.status.poweredOn | tostring)'
```

### Review the bmh provisioning state

```console
oc get bmh -n openshift-machine-api -ojson | jq -r '.items[] | .metadata.name + "   ProvsioningState:" +  .status.provisioning.state'
```

### Change the provisioning state (if necessary)

```console
oc patch -n openshift-machine-api bmh $NODE_NAME --subresource status --type json -p '[{"op":"replace","path":"/status/provisioning/state","value":"unmanaged"}]'
```

### Set the machine provisioned state (if necessary)

```
oc  patch -n openshift-machine-api machines.machine.openshift.io $NEW_MACHINE_NAME -n openshift-machine-api --subresource status --type json -p '[{"op":"replace","path":"/status/phase","value":"Provisioned"}]'
```

## Additonal Informational Commands

- Generate the providerID lines for control plane nodes

```console
oc get -n openshift-machine-api baremetalhost -l installer.openshift.io/role=control-plane -ojson | jq -r '.items[] | "baremetalhost:///openshift-machine-api/" + .metadata.name + "/" + .metadata.uid'
````

- Identify the cluster

```console
oc get machines.machine.openshift.io -n openshift-machine-api -l machine.openshift.io/cluster-api-machine-role=master  -L machine.openshift.io/cluster-api-cluster 
```










###################
 addresses=$(oc get node -n openshift-machine-api "${NODE_NAME}" -o json | jq -c '.status.addresses')
 machine_data=$(oc get machines.machine.openshift.io -n openshift-machine-api -o json "${NEW_MACHINE_NAME}")
 host=$(echo "$machine_data" | jq -c -r '.metadata.annotations["metal3.io/BareMetalHost"]' | cut -f2 -d/ )

if [ -z "$host" ]; then
    echo "Machine $machine is not linked to a host yet." 1>&2
    exit 1
fi


hostname=$(echo "${addresses}" | jq -c -r '.[] | select(. | .type == "Hostname") | .address')
nic=$(echo "${addresses}" | jq -c -r '.[] | select(. | .type == "InternalIP") | .address')

read -r -d '' host_patch << EOF
{
  "status": {
    "hardware": {
      "hostname": "${hostname}",
      "nics": [
         { 
           "ip": "${nic}",
           "mac": "00:00:00:00:00:00",
           "model": "unknown",
           "speedGbps": 10,
           "vlanId": 0,
           "pxe": true,
           "name": "eth1"
         }
      ],
    }
  }
}
EOF

oc patch baremetalhost ${NEW_MACHINE_NAME} --type='json' -p......=

oc patch pod <pod-name> --type='json' -p='[{"op": "replace", "path": "/spec/containers/0/image", "value":"new-image-name"}]'


######

```console

  RELEASE_IMAGE_DIGEST=$(oc get clusterversion -o jsonpath='{.items[0].status.history[0].image}')

  BAREMETAL_OPERATOR_IMAGE=$(podman run --quiet --rm --net=none "${RELEASE_IMAGE_DIGEST}" image "baremetal-operator")

  oc get -o json node ab05ru12 | jq -r '.status.nodeInfo.systemUUID'

  HARDWARE_DETAILS=$(podman run --quiet --net=host \
      --rm \
      --name baremetal-operator \
      --entrypoint /get-hardware-details \
      "${BAREMETAL_OPERATOR_IMAGE}" \
      http://localhost:5050/v1 "$node" | jq '{hardware: .}')

  oc annotate --overwrite -n openshift-machine-api baremetalhosts "$name" 'baremetalhost.metal3.io/status'="$HARDWARE_DETAILS"

```





  ports:
  - name: ironic
    port: 6388
    protocol: TCP
    targetPort: 6388
  - name: http
    port: 6180
    protocol: TCP
    targetPort: 6180
  - name: ironic-api
    port: 6385
    protocol: TCP
    targetPort: 6385
metal3-state.openshift-machine-api.svc.cluster.loc

4c4c4544-0044-5010-8051-c6c04f534432

/get-hardware-details http://10.150.49.111

