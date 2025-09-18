#!/bin/bash

for node in $(oc get nodes --no-headers=true -o custom-columns=NAME:.metadata.name)
do
  echo "Cleaning node: $node"

  oc debug -q node/$node -- chroot /host bash -c "podman images | grep redhat-operator-index | tail -1 | awk '{print $3}' | xargs -r podman rmi"

done
