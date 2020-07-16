# Ansible role 'install_nfs'

Ansible role to install and configure an NFS server as well as add the NFS server as a storage class to OpenShift

## Requirements

- No Requirements

## Dependencies

- No Dependencies

## Role Variables

| Variable                | Default                       | Comments                                                                                |
| :---                    | :---                          | :---                                                                                    |
| nfs_exports             |                     
| nfs_rpcbind_state       |
| nfs_rpcbind_enabled     |
| air_gapped              |
| mirror_registry         |
| mirror_transport        |
| kubeconfig              |
| ocp_base_domain         |
| ocp_cluster_name        |
| nfs_namespace           |
| ssl_enabled             |
| nfs_server              |
| nfs_path                |
| nfs_sc_default          | 


Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

## License

2-clause BSD license, see [LICENSE.md](LICENSE.md)

## Contributors

- [Dan Clark](https://github.com/dmc5179/) (maintainer)
