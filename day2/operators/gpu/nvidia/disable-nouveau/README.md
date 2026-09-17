# Machine Config to disable nouveau driver

## Update butane with your OCP version

```console
vim 99-worker-disable-nouveau.bu
```

## Generate Machine Config from Butane Config

```console
butane 99-worker-disable-nouveau.bu -o 99-worker-disable-nouveau.yaml
```

## Apply Machine Config

```console
oc apply -f 99-worker-disable-nouveau.yaml
```



openshift:
  kernel_arguments:
    - modprobe.blacklist=nouveau
    - rd.driver.blacklist=nouveau
    - nouveau.modeset=0

