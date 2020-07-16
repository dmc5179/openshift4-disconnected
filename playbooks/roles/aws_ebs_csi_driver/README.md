# Ansible role 'aws_ebs_csi_driver'

A simple role for installing the AWS EBS CSI Storage Driver on OpenShift

## Requirements

- There are 2 methods to deploy the AWS EBS CSI Storage Driver:
  - IAM roles
  - API Keys

For some AWS environments where API Keys are ephemeral, only the IAM deployment can be used. The IAM deployment model requires the AWS EBS CSI Storage pods
be able to access the AWS metadata API endpoint. This endpoint is considered a link local address which OpenShift will not route. To resolve this issue the base
AWS EBS CSI Storage Driver deployment yaml has been modified to enable hostPorts so the AWS EBS CSI Storage pods can access the AWS metadata endpoints.

For Some AWS environments that API has customer SSL certificates. The AWS EBS CSI Storage Driver deployment yaml has also been modified to allow the AWS CSI Storage pods
to mount the /etc/pki directory of the underlying host node. The allows the pods to validate the certificates used to sign the AWS API endpoints.

Note: The AWS EBS CSI Storage driver is not directly supported by Red Hat.

## Dependencies

- No Dependencies

## Role Variables

| Variable                                     | Default                       | Comments                                                                                |
| :---                                         | :---                          | :---                                                                                    |

## Installing the Image Content Source Policy for Air-gap and disconnected OpenShift clusterversion




Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

## License

2-clause BSD license, see [LICENSE.md](LICENSE.md)

## Contributors

- [Dan Clark](https://github.com/dmc5179/) (maintainer)
