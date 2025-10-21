1. Start the VM on a physical node, let it boot and reach that state where the VM is apparently doing nothing yet the CPU usage is high.

2. SSH to the node
   # ssh core<node running the VM>

3. Find its kernel version
   # uname -r

4. Enter a toolbox pod
   # sudo su
   # toolbox

5. For that specific kernel version from step [3], get the corresponding kernel-tools-libs and kernel-tools rpm packages from our portal:
   https://access.redhat.com/downloads/content/kernel-tools-libs/5.14.0-570.32.1.el9_6/x86_64/fd431d51/package
   https://access.redhat.com/downloads/content/kernel-tools/5.14.0-570.32.1.el9_6/x86_64/fd431d51/package
   NOTE: change the version at the top to match step 3.

6. Also get this one:
   https://access.redhat.com/downloads/content/pciutils-libs/3.7.0-7.el9/x86_64/fd431d51/package

7. Copy them to the toolbox pod (I like to just right click on the links above for download and then just curl from inside the pod to get them there)

8. Install the packages inside the toolbox 
   # dnf install pciutils-libs-3.7.0-7.el9.x86_64.rpm kernel-tools-libs-5.14.0-570.32.1.el9_6.x86_64.rpm kernel-tools-5.14.0-570.32.1.el9_6.x86_64.rpm 
   NOTE: change the versions to match yours

9. Find the qemu-kvm process PID of the VM started in step 1.
   # ps -ef | grep qemu-kvm | grep <VM NAME>

10. Get kvm_stat for that qemu-kvm PID, for 1s a few times
   # kvm_stat -p <PID from above> -1
   # sleep 5
   # kvm_stat -p <PID from above> -1
   # sleep 5
   # kvm_stat -p <PID from above> -1

11. Please show us the outputs of the kvm_stats
