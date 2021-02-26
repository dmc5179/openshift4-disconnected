# Install and Configure Storage Options for OpenShift 4

## NFS Storage

### Install and Configure NFS Server

  ```
  ansible-playbook nfs_server.yaml
  ```

### Add NFS as Storage Provider in OpenShift 4

  ```
  ansible-playbook nfs_provider.yaml
  ```

## Local Storage

  ```
  ansible-playbook local_storage.yaml
  ```

