#!/bin/bash

IMAGE="redhat-operator-index"

for node in $(oc get nodes --no-headers=true -o custom-columns=NAME:.metadata.name)
do
  echo "Cleaning node: $node"

  oc debug -q node/$node -- chroot /host bash -c "podman images | grep ${IMAGE}  | tail -1 | awk '{print $3}' | xargs -r podman rmi"

done

exit 0


# Old way of doing this without the substitution above which I haven't tested
#for node in $(oc get nodes --no-headers=true -o custom-columns=NAME:.metadata.name)
#do
#  echo "Cleaning node: $node"
#
#  oc debug -q node/$node -- chroot /host bash -c "podman images | grep redhat-operator-index | tail -1 | awk '{print $3}' | xargs -r podman rmi"
#
#done
