#!/bin/bash -xe

#SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Source the environment file with the default settings
#source "${SCRIPT_DIR}/../env.sh"

# Time server the OpenShift 4 cluster will use
NTP_SERVER=10.0.255.100

# Create the new chrony.conf that the OpenShift 4 cluster will use
cat << EOF | base64 | tr -d '\n' > ./chrony.conf
    server ${NTP_SERVER} iburst
    driftfile /var/lib/chrony/drift
    makestep 1.0 3
    rtcsync
    logdir /var/log/chrony
EOF

# Read in the new chrony.conf file
CHRONY_B64=$(cat ./chrony.conf)

# Create a machine config to set chrony config on master nodes
cat << EOF > ./99_master-chrony-configuration.yaml
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
          source: data:text/plain;charset=utf-8;base64,${CHRONY_B64}
          verification: {}
        filesystem: root
        mode: 420
        path: /etc/chrony.conf
  osImageURL: ""
EOF

# Create a machine config to set chrony config on worker nodes
cat << EOF > ./99_worker-chrony-configuration.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: worker
  name: workers-chrony-configuration
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
          source: data:text/plain;charset=utf-8;base64,${CHRONY_B64}
          verification: {}
        filesystem: root
        mode: 420
        path: /etc/chrony.conf
  osImageURL: ""
EOF

oc apply -f ./99_master-chrony-configuration.yaml
oc apply -f ./99_worker-chrony-configuration.yaml

exit 0
