# Ansible role 'mirror_rhcos'

Ansible role for mirroring the Red Hat CoreOS install media.
Role includes variables for mirroring RHCOS as:
- VMDK
- ISO
- Azure VD
- GPE

## Requirements

- No Requirements

## Dependencies

- No Dependencies

## Role Variables

| Variable                    | Default                       | Comments          |
| :---                        | :---                          | :---              |
| run_as_root                 |                               |                   |
| mirror_base                 |                               |                   |
| air_gapped                  |                               |                   |
| mirror_registry             |                               |                   |
| mirror_transport            |                               |                   |

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
