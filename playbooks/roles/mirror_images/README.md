# Ansible role 'mirror_images'

Role for mirroring container images for disconnected and air-gapped environments.
This role is intended to list images outside of the base images needed to install OpenShift and the images needed for OperatorHub

## Requirements

- No Requirements

## Dependencies

- No Dependencies

## Role Variables

| Variable                         | Default                       | Comments                                                                                |
| :---                             | :---                          | :---                                                                                    |
| air_gapped                       |
| mirror_registry                  |
| mirror_transport                 |
| mirror_tower                     |
| mirror_compliance_operator       |         
| pull_secret                      |
| mirror_base                      |

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
