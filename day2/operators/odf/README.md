# Set spinning drives to non-rotational on each reboot

This guide assumes we are trying to use the spinnging disks in 3 worker nodes for ODF.
This includes the use case where there are only 3 nodes in the cluster such that they are both control plane and worker nodes

## Identify the drives

Use 'oc debug node/<node-name>' to get onto the first node
Run 'chroot /host'
Run 'lsblk' # list disks

The configuration in the next steps contains this line "target_disks=$(lsblk -dn -o NAME,SIZE | awk '$2 == "2.2T" {print $1}')"
which will search for all block devices that are exactly 2.2T in size. The search size can be changed or the list of devices can be set manually to the target_disks variable


```console
butane 99-set-nonrotational-mc.bu -o 99-set-nonrotational-mc.yaml
```

```console
oc create -f 99-set-nonrotational-mc.yaml
```
