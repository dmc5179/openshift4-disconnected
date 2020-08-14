#!/bin/bash -xe

REGISTRY="registry.caas.cia.ic.gov:5000"

# Read in the new chrony.conf file
ICSP_B64=$(cat ./icsp.conf | sed "s|registry.example.com|${REGISTRY}|g" | base64 | tr -d '\n')

# Create a machine config to set the private registry for master nodes
cat << EOF > ./99_master-private-registry-configuration.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: master
  name: masters-chrony-configuration
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
cat << EOF > ./99_worker-private-registry-configuration.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: worker
  name: masters-chrony-configuration
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

#oc apply -f ./99_master-private-registry-configuration.yaml
oc apply -f ./99_worker-private-registry-configuration.yaml

exit 0
