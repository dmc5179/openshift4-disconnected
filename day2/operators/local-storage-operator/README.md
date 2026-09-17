# Deploying the local storage operator

## Install Operator from Operator Hub

## Wiping disks on each bare metal node

### Removing old ADM software RAID fingerprints

If the disk has old software RAID fingerprints, those will need to be removed first as the wipefs command will not clear them out

```bash
lsblk
mdadm --stop /dev/mdX
mdadm --zero-superblock /dev/sdX
```

### Clearing old partitions

Run wipefs command weather or not mdadm commands above were needed or used.

```bash
wipefs -a /dev/sdX
```

### Deploy LSO Volume Discover

```bash
oc create -f
```
