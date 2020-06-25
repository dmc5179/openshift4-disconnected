# Ansible role 'install_pxe'

## Requirements

- No Requirements

## Dependencies

- No Dependencies

## Role Variables

| Variable                  | Default                       | Comments                                                                                |
| :---                      | :---                          | :---                                                                                    |
| tftp_root_directory       | 
| pxeserver_directory       |
| pxeserver_path            |
| pxeserver_ip              |
| pxeserver_images          |
| image_url                 |
| ignition_url              |
| disk                      |


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
