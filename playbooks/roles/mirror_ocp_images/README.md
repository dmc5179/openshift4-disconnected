# Ansible role 'mirror_ocp_images'

Role for mirroring the OpenShift base container images needed to install an OpenShift cluster

## Requirements

- No Requirements

## Dependencies

- No Dependencies

## Role Variables

| Variable             | Default                       | Comments                                                                                |
| :---                 | :---                          | :---                                                                                    |
| ocp_release          |
| arch                 |
| local_reg            |
| local_repo           |
| product_repo         |
| mirror_base          |
| pull_secret          |
| release_name         |
| mirror_to_reg        |
| mirror_to_dir        |
| air_gapped           |
| mirror_registry      |
| mirror_transport     |

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
