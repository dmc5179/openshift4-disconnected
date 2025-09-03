# Adding an SSH warning banner to the nodes

## This doc assumes the compliance operator is in place

The butane binary is required to create the machine configs and can be found here:
https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/butane/latest/butane-amd64

### Create and apply SSH warning banner machine config to worker nodes

- Use butane to generate the machine config yaml for worker nodes
```console
butane banner-worker.bu -o banner-worker.yaml
```

- Apply machine config to the cluster
```console
oc apply -f banner-worker.yaml
```

- Use butane to generate the machine config yaml for master nodes
```console
butane banner-master.bu -o banner-master.yaml
```

- Apply machine config to the cluster
```console
oc apply -f banner-master.yaml
```

- Check the machine config pool and cluster nodes to wait for machine configs to apply to nodes
```console
oc get mcp
oc get nodes
```

## Below describes how this would be done when the compliance operator is not in place. This has not been tested yet.

- No compliance operator means we need to create /etc/ssh/ssh_config.d/50-warning-banner.conf # to set the "Banner" field. Unsure if this will override the Banner field in sshd_config but that field is commented out by default when the compliance operator is not present
