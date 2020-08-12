#!/bin/bash -xe

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

# Create a machine config to set the new chrony 
cat << EOF > ./99_masters-chrony-configuration.yaml
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

oc apply -f ./99_masters-chrony-configuration.yaml

exit 0
