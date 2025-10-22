# one liner but need to know these vars like REGISTRY_AUTHFILE and CEPHTOOLS_IMAGE
# This podman command can be run against each disk like /dev/sdX
#/usr/bin/podman run --authfile ${REGISTRY_AUTHFILE} --rm -ti --privileged --device ${DEVICE} --entrypoint ceph-bluestore-tool ${CEPHTOOLS_IMAGE} zap-device --dev ${DEVICE} --yes-i-really-really-mean-it

##############################################################
# Stick this in a for loop for each DEVICE to wipe
DISK="/dev/sdX"

# Zap the disk to a fresh, usable state (zap-all is important, b/c MBR has to be clean)
sgdisk --zap-all $DISK

# Wipe portions of the disk to remove more LVM metadata that may be present
dd if=/dev/zero of="$DISK" bs=1K count=200 oflag=direct,dsync seek=0 # Clear at offset 0
dd if=/dev/zero of="$DISK" bs=1K count=200 oflag=direct,dsync seek=$((1 * 1024**2)) # Clear at offset 1GB
dd if=/dev/zero of="$DISK" bs=1K count=200 oflag=direct,dsync seek=$((10 * 1024**2)) # Clear at offset 10GB
dd if=/dev/zero of="$DISK" bs=1K count=200 oflag=direct,dsync seek=$((100 * 1024**2)) # Clear at offset 100GB
dd if=/dev/zero of="$DISK" bs=1K count=200 oflag=direct,dsync seek=$((1000 * 1024**2)) # Clear at offset 1000GB

# SSDs may be better cleaned with blkdiscard instead of dd
blkdiscard $DISK

# Inform the OS of partition table changes
partprobe $DISK
