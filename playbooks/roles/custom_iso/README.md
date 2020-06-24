# Ansible role 'custom_iso'

A simple role for creating a custom Red Hat CoreOS (RHCOS) ISO for use with static IP based OpenShift clusters. Specific responsibilities of this role:

- Install necessary packages for creating an ISO image file
- Setting the kernel and boot loader options for each custom_iso
- Creating an ISO image for each host in the OpenShift cluster

## Requirements

- No Requirements

## Dependencies

- No Dependencies

## Role Variables

| Variable                                     | Default                       | Comments                                                                                |
| :---                                         | :---                          | :---                                                                                    |
| `tmp_dir`                                    | /tmp/rhcos                    | Location for staging ISO builds                                                         |
| 'openshift_bootstrap'                        | {}                            | Bootstrap node configuration. See |
| 'openshift_masters'                          | {}                            | Master nodes configuration. See |
| 'openshift_workers'                          | {}                            | Worker nodes configuration. See |

## License

2-clause BSD license, see [LICENSE.md](LICENSE.md)

## Contributors

- [Dan Clark](https://github.com/dmc5179/) (maintainer)
