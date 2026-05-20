# Create VMware Virtual Disk Development Kit (VDDK) Image
- The Migration Toolkit for Virtualization (MTV) can use the VDDK SDK to accelerate transferring virtual disks from VMware vSphere.

- Download the current version of Vsphere VDDK (VMware account credentials required): https://developer.broadcom.com/sdks/vmware-virtual-disk-development-kit-vddk/latest

- RH Docs: https://docs.redhat.com/en/documentation/migration_toolkit_for_virtualization/2.11/html/planning_your_migration_to_red_hat_openshift_virtualization/assembly_provider-specific-requirements-for-migration_mtv#creating-vddk-image_mtv

# Create a working directory to build the image
```console
mkdir /tmp/vddk-build && cd /tmp/vddk-build
```
# Extract the contents of the VMware-vix tarball to working directory
tar -xzf /full/path/VMware-vix-disklib-<version>.x86_64.tar.gz --directory /tmp/vddk-build

# Log into disconnected registry
```console
podman login <registry_route_or_server_path>
```

# Create Dockerfile in working directory. Update the FROM to disconnected registry
```console
cat > Dockerfile <<EOF
FROM registry.access.redhat.com/ubi8/ubi-minimal  #change me
USER 1001
COPY vmware-vix-disklib-distrib /vmware-vix-disklib-distrib
RUN mkdir -p /opt
ENTRYPOINT ["cp", "-r", "/vmware-vix-disklib-distrib", "/opt"]
EOF
```

# Build the image
```console
podman build . -t <registry_route_or_server_path>/vddk:<tag>
```

# Push image to disconnected registry
```console
podman push <registry_route_or_server_path>/vddk:<tag>
```
