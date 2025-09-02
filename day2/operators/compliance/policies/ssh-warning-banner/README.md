# Adding an SSH warning banner to the nodes

## This doc assumes the compliance operator is in place

The butane binary is required to create the machine configs and can be found here:
https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/butane/latest/butane-amd64

The same banner.bu file is for worker nodes. Change the role to 'master' for master nodes.
Will need to create and apply both to cover all nodes.
TODO: Find label that covers master and worker nodes

```console
butane banner.bu -o banner.yaml
```

```console
oc apply -f banner.yaml
```



- No compliance == no banner in sshd_config

Will need to create /etc/ssh/ssh_config.d/50-warning-banner.conf # to set the "Banner" field
Will need to create banner file at /etc/issue

- Compliance == Banner /etc/issue
Will need to create banner file at /etc/issue

