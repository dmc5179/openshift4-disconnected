- Windows Hyper-V enlightenments causing issues

https://access.redhat.com/solutions/7129100

- Ensure all enlightenments are enabled in the VirtualMachine spec for the Windows VM. For example
```console
oc get vm windows-2022 -o yaml | yq '.spec.template.spec.domain.features.hyperv'
frequencies: {}
ipi: {}
reenlightenment: {}
relaxed: {}
reset: {}
runtime: {}
spinlocks:
  spinlocks: 8191
synic: {}
synictimer:
  direct: {}
tlbflush: {}
vapic: {}
vpindex: {}
```

- Add the evmcs field with oc edit
```console
oc edit VirtualMachine windows-2022

apiVersion: kubevirt.io/v1
kind: VirtualMachine
spec:
  template:
    spec:
      domain:
        features:
          hyperv:
            evmcs: {}      <--- add to the list
```
