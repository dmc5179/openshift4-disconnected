# ingress_certificate

Ansible role to update the OpenShift 4 ingress certificate

## Requirements

- No Requirements

## Dependencies

- No Dependencies

## Role Variables

| Variable       | Default                 | Comments                          |
| :---           | :---                    | :---                              |
| root_ca        | 'root_ca.pem'           | Name of the root ca pem file      |
| ingress_cert   | 'ingress_cert.pem'      | Name of the certificate pem file  |
| full_chain     | 'full_chain.pem'        | Name of the full chain pem file   |
| ingress_key    | 'ingress_cert_key.pem'  | Name of the certificate key file  |


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

