# Ansible role 'generate_ignition'

## Requirements

- No Requirements

## Dependencies

- No Dependencies

## Role Variables

| Variable                                      | Default                                             | Comments                                                                                |
| :---                                          | :---                                                | :---                                                                                    |
| openshift_install                             | openshift-install                                   | Path to the openshift-install binary |
| openshift_client                              | oc                                                  | Path to the oc command  |
| kubectl                                       | kubectl                                             | Path to the kubectl command  |
| kubeauth                                      | ~/.kube/auth                                        | Path where the kube auth will be copied to  |
| mirror_base                                   | /opt/openshift                                      | Path to the base mirror directory |
| ignition_configs                              | {{ mirror_base }}/cluster                           | Subpath of the mirror directory where the manifests and ignition files will be  |
| pull_secret                                   | {{ mirror_base }}/pull-secret.txt                  | Pull secret to add to the cluster. Should include auth for pulling from disconnected registry  |
| master_schedulable                            | false                                               | For UPI clusters set this to false  |
| cluster_channel                               | fast                                                | Cluster Update Channel  |
| fips                                          | true                                                | Enable FIPS  |
| ssh_public_key_file                           | ~/.ssh/id_ed25519.pub                               |   |
| ocp_base_domain                               | example.com                                         |   |
| ocp_cluster_name                              | caas                                                |   |
| worker_count                                  | 3                                                   |   |
| master_count                                  | 3                                                   |   |
| air_gapped                                    | true                                                |   |
| mirror_registry                               | localhost:5000                                      |   |
| mirror_transport                              | https                                               |   |
| fips_enabled                                  | false                                               |   |
| certificate_bundle                            | /opt/openshift/etc/docker-registry/pki/registry.crt |   |
| platform                                      | none                                                |   |
| cluster_network_cidr                          | 10.128.0.0/14                                       |   |
| cluster_network_prefix                        | 23                                                  |   |
| service_network_cidr                          | 172.30.0.0/16                                       |   |
| mtu                                           | 1450                                                |   |
| vxlanPort                                     | 4789                                                |   |
| network_policy                                | NetworkPolicy                                       |   |


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
