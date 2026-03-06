# Adding a node to an existing OpenShift cluster with the agent based installer

## Create the nodes-config.yaml

Update the example nodes-config.yaml with the MAC/IP/Network/Disk information for your new node or nodes

## Generate the additional ISO
Generate a secondary ISO that the new node, or nodes, will boot to

. Ensure that your oc CLI is authenticated to your OpenShift cluster as a cluster admin. Run "oc get nodes" to confirm

```console
mkdir /tmp/assests  # Change to a directory of your choice and change all references to that directory below
cp nodes-config.yaml /tmp/assests
oc adm node-image create --dir=/tmp/assets
```

## Boot the ISO

. Boot the nodes to be added to the new ISO that has been created under /tmp/assets in this example

## Follow the installation of the node
```console
oc adm node-image monitor --ip-addresses 192.168.111.83,192.168.111.84  #Change to the IP or IPs of the node to be added to the cluster
```
