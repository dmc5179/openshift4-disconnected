# Ansible role 'compliance-operator'

A simple role for deploying the [Red Hat Compliance Operator](https://github.com/openshift/compliance-operator) on Red Hat openshift

The compliance-operator is a OpenShift Operator that allows an administrator to run compliance scans and provide remediations for the issues found. The operator leverages OpenSCAP under the hood to perform the scans.

By default, the operator runs in the openshift-compliance namespace, so make sure all namespaced resources like the deployment or the custom resources the operator consumes are created there. However, it is possible for the operator to be deployed in other namespaces as well.

The compliance operator is still Tech Preview

## Requirements

- Currently the compliance operator does not support digest based image deployment. This requires modification of the registries in
  /etc/containers/registries.conf on each node

## Dependencies

- No Dependencies

## Role Variables

| Variable                                     | Default                       | Comments                                                                                |
| :---                                         | :---                          | :---                                                                                    |

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
