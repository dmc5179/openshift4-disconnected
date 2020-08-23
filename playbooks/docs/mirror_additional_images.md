# Mirroring Addtional Container Images

- Additional container images may be necessary to install other applications on top of OpenShift. 

Currently this playbook/role will mirror all of the images described in each variable file under roles/mirror_images/vars
In a future realease this will be configurable to add more variable files and skip others.

- To mirror the additional images 


```
ansible-playbook pull_additional_images.yaml
```

- To push the additional images to a registry in the disconnected environment


```
ansible-playbook push_additional_images.yaml
```

# Notes

This role does not currently support mirroring to a registry (like the local registry) or mirroring to disk