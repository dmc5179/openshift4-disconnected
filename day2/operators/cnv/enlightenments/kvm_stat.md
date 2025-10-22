1. Start the VM on a physical node, let it boot and reach that state where the VM is apparently doing nothing yet the CPU usage is high.

2. Determine which OpenShift node the VM is running on
```console
oc get -o yaml VirtualMachine <VM name> | grep -i node
```

3. SSH to the node
```console
ssh core@<node running the VM>
```

4. Find its kernel version
```console
uname -r
```

5. Enter a toolbox pod
```console
sudo -s
toolbox
```

6. For that specific kernel version from step [4], install the RPMs into the toolbox container:
- Note that this may require downloading the RPMs from RHN or a yum repo and copying them into the toolbox RPM
- You can also rebuild the toolbox container image with these packages included and push it to your registry
- The toolbox container image name can be found in the toolbox script "which toolbox"
```console
dnf install -y kernel-tools-$(uname -r) kernel-tools-libs-$(uname -r) pciutils-libs
```

7. Find the qemu-kvm process PID of the VM started in step 1.
```console
ps -ef | grep qemu-kvm | grep <VM NAME>
```

8. Get kvm_stat for that qemu-kvm PID, for 1s a few times
```console
kvm_stat -p <PID from above> -1
sleep 5
kvm_stat -p <PID from above> -1
sleep 5
kvm_stat -p <PID from above> -1
```

9. Note the outputs of the kvm_stats
