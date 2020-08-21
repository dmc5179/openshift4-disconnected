# Creating a private registry with Ansible and Podman

This guide will walk you through using ansible to setup a local docker registry using podman

Everything in this guide will use the variable names from the role which you will need to have configured in a previous step.


- Run the ansible playbook to create the private registry

```
  ansible-playbook registry_server.yaml
```

- Once the registry has been installed, check that it is running as the user it was installed as by running
```
podman ps
```

- In a previous section a pull secret file was downloaded from the Red Hat infrastructure page. We need to add authentication tokens for the private registry to that file so that the file contains authentication tokens for both registries involved in the mirror process. Assuming that file was downloaded to $HOME/pull-secret.json run the following command. This will prompt for the username and password used when creating the private registry.

```
podman login --authfile=$HOME/pull-secret.json < registry hostname : registry port>
```