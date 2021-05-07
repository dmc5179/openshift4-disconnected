#!/bin/bash -xe

##########################
# This should be the location where you mirrored the OpenShift 4 images used to build the cluster
# like myregistry.mydomain.com:5000/ocp4/openshift4
PRIVATE_REGISTRY="myregistry.mydomain.com:5000"
PRIVATE_REPO="ocp4/openshift4"

# Read in the new chrony.conf file
ICSP_B64=$(cat ./icsp.conf | sed "s|registry.example.com|${PRIVATE_REGISTRY}|g" | sed "s|LOCAL_REPO|${PRIVATE_REPO}|g" | base64 -w 0)

# Create a machine config to set the private registry for master nodes
rm -f ./99_master-private-registry-configuration.yaml
cat << EOF > ./99_master-private-registry-configuration.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: master
  name: master-priv-reg-configuration
spec:
  config:
    ignition:
      config: {}
      security:
        tls: {}
      timeouts: {}
      version: 2.2.0
    networkd: {}
    passwd: {}
    storage:
      files:
      - contents:
          source: data:text/plain;charset=utf-8;base64,${ICSP_B64}
          verification: {}
        filesystem: root
        mode: 420
        path: /etc/containers/registries.conf
  osImageURL: ""
EOF

# Create a machine config to set the private registry ICSP for worker nodes
rm -f ./99_worker-private-registry-configuration.yaml
cat << EOF > ./99_worker-private-registry-configuration.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: worker
  name: worker-priv-reg-configuration
spec:
  config:
    ignition:
      config: {}
      security:
        tls: {}
      timeouts: {}
      version: 2.2.0
    networkd: {}
    passwd: {}
    storage:
      files:
      - contents:
          source: data:text/plain;charset=utf-8;base64,${ICSP_B64}
          verification: {}
        filesystem: root
        mode: 420
        path: /etc/containers/registries.conf
  osImageURL: ""
EOF

oc apply -f ./99_master-private-registry-configuration.yaml
oc apply -f ./99_worker-private-registry-configuration.yaml

exit 0
