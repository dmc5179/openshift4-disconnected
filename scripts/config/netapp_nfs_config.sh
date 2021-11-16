#!/bin/bash -xe

NFS3=$(echo 'options tcp_max_slot_table_entries=128' | base64 -w 0)  # sunrpc
NFS4=$(echo 'options nfs max_session_slots=180' | base64 -w 0)  #cfsclient.conf

rm -f ./99_master-nfsv3-config.yaml
cat << EOF > ./99_master-nfsv3-config.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: master
  name: master-nfsv3-config
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
          source: data:text/plain;charset=utf-8;base64,${NFS3}
          verification: {}
        filesystem: root
        mode: 420
        path: /etc/modprobe.d/sunrpc.conf
  osImageURL: ""
EOF

rm -f ./99_worker-nfsv3-config.yaml
cat << EOF > ./99_worker-nfsv3-config.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: worker
  name: worker-nfsv3-config
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
          source: data:text/plain;charset=utf-8;base64,${NFS3}
          verification: {}
        filesystem: root
        mode: 420
        path: /etc/modprobe.d/sunrpc.conf
  osImageURL: ""
EOF

##########################
# NFSv4

rm -f ./99_master-nfsv4-config.yaml
cat << EOF > ./99_master-nfsv4-config.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: master
  name: master-nfsv4-config
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
          source: data:text/plain;charset=utf-8;base64,${NFS4}
          verification: {}
        filesystem: root
        mode: 420
        path: /etc/modprobe.d/sunrpc.conf
  osImageURL: ""
EOF

rm -f ./99_worker-nfsv4-config.yaml
cat << EOF > ./99_worker-nfsv4-config.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: worker
  name: worker-nfsv4-config
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
          source: data:text/plain;charset=utf-8;base64,${NFS4}
          verification: {}
        filesystem: root
        mode: 420
        path: /etc/modprobe.d/sunrpc.conf
  osImageURL: ""
EOF

#oc apply -f ./99_master-nfsv3-config.yaml
#oc apply -f ./99_worker-nfsv3-config.yaml
#oc apply -f ./99_master-nfsv4-config.yaml
#oc apply -f ./99_worker-nfsv4-config.yaml

exit 0
