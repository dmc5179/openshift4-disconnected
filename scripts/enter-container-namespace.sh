#!/bin/bash

# Script/Steps to enter a container's group of namespaces from an OCP node
oc get -o yaml pod <pod> | grep -i host
oc debug node/<host>
chroot /host
crictl ps | grep "container name"
PID=$(crictl inspect <container-id> | jq '.info.pid')
nsenter -t $PID -m -u -i -n -p -- bash
