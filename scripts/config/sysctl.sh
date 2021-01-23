#!/bin/bash

rm -f /tmp/sysctl-system.conf
rm -f /tmp/sysctl-user.conf

cat << EOF > /tmp/sysctl-system.conf
fs.file-max = 65535
EOF

cat << EOF > /tmp/sysctl-user.conf
*     soft     nofile     65535
*     hard     nofile     65535
EOF

SYSCTL_SYSTEM_B64=$(cat /tmp/sysctl-system.conf | base64 -w 0)
SYSCTL_USER_B64=$(cat /tmp/sysctl-user.conf | base64 -w 0)

echo "System: $SYSCTL_SYSTEM_B64"
echo "User: $SYSCTL_USER_B64"

exit 0

# Create a machine config to set the private registry for master nodes
rm -f ./99_master-sysctl-system-configuration.yaml
cat << EOF > ./99_master-sysctl-system-configuration.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: master
  name: master-sysctl-system-configuration
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
          source: data:text/plain;charset=utf-8;base64,${SYSCTL_SYSTEM_B64}
          verification: {}
        filesystem: root
        mode: 420
        path: /etc/sysctl.d/99-openshift-master.conf
  osImageURL: ""
EOF


# Create a machine config to set the private registry for master nodes
rm -f ./99_master-sysctl-user-configuration.yaml
cat << EOF > ./99_master-sysctl-user-configuration.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: master
  name: master-sysctl-user-configuration
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
          source: data:text/plain;charset=utf-8;base64,${SYSCTL_USER_B64}
          verification: {}
        filesystem: root
        mode: 420
        path: /etc/security/limits.d/99-openshift-master.conf
  osImageURL: ""
EOF


rm -f ./99_worker-sysctl-system-configuration.yaml
cat << EOF > ./99_worker-sysctl-system-configuration.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: worker
  name: worker-sysctl-system-configuration
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
          source: data:text/plain;charset=utf-8;base64,${SYSCTL_SYSTEM_B64}
          verification: {}
        filesystem: root
        mode: 420
        path: /etc/sysctl.d/99-openshift-worker.conf
  osImageURL: ""
EOF


rm -f ./99_worker-sysctl-user-configuration.yaml
cat << EOF > ./99_worker-sysctl-user-configuration.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: worker
  name: worker-sysctl-user-configuration
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
          source: data:text/plain;charset=utf-8;base64,${SYSCTL_USER_B64}
          verification: {}
        filesystem: root
        mode: 420
        path: /etc/security/limits.d/99-openshift-worker.conf
  osImageURL: ""
EOF

rm -f /tmp/sysctl-system.conf
rm -f /tmp/sysctl-user.conf

exit 0
