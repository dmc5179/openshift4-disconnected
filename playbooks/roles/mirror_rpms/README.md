# Ansible role 'mirror_rpms'

Ansible role for mirroring Red Hat RPMS for install OpenShift in a disconnected or air-gap environment

## Requirements

- No Requirements

## Dependencies

- No Dependencies

## Role Variables

| Variable                   | Default                       | Comments                                                                                |
| :---                       | :---                          | :---                                                                                    |
| run_as_root                | 
| repo_depth                 |
| rhel7_enabled              |
| rhel7_repositories         |
| epel7_enabled              |
| epel7_repository           |
| rhel8_enabled              |
| rhel8_repositories         |
| epel8_enabled              |
| epel8_repository           |
| mirror_base                |
| repo_mirror_base           |
| repo_srv_base              |
| arch                       |
| air_gapped                 |
| mirror_registry            |
| mirror_transport           |

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
