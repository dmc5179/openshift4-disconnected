# Install and Configure Storage Options for OpenShift 4

## NFS Storage

### Install and Configure NFS Server

  ```bash
  ansible-playbook nfs_server.yaml
  ```

### Add NFS as Storage Provider in OpenShift 4

  ```bash
  ansible-playbook nfs_provider.yaml
  ```

## Local Storage

  ```bash
  ansible-playbook local_storage.yaml
  ```

