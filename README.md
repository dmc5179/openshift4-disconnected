# OpenShift 4 Disconnected

**Table of Contents**
  - [Purpose](#Purpose)
  - [Requirements](#Requirements)
  - [Dependencies](#Dependencies)
  - [Internet Connected Side](#Internet-Connected-Side)
  - [Air Gap Side](#Air-Gap-Side)
  - [Miscellaneous](#Miscellaneous)
  - [License](#License)
  - [Contributors](#Contributors)

### Purpose 

This repository contains scripts, ansible roles, and other toosl for deploying an OpenShift 4 cluster in an air-gapped environment.

The repository has been tested to work for installs of OpenShift 4.3, 4.4, and 4.5.

The helper node in the internet connected environment, as well as the helper node in the air-gap environment have been tested on RHEL 8.
Most things will still work on RHEL 7 but not all.

These tools can also be used in semi-disconnected environments which can be reached through a proxy host from the public internet.

### Requirements

### Dependencies

### Internet Connected Side

  This section covers getting started on the internet connected helper node. This is where all tools and images will be downloaded to


- [Create main variable file](https://github.com/dmc5179/openshift4-disconnected/blob/master/playbooks/docs/vars-all.md)

- [Create a docker registry for mirrored images](https://github.com/dmc5179/openshift4-disconnected/blob/master/playbooks/docs/registry_server.md)

- [Mirror OpenShift Cluster Images](https://github.com/dmc5179/openshift4-disconnected/blob/master/playbooks/docs/mirror_ocp_images.md)

- [Mirror Red Hat CoreOS](https://github.com/dmc5179/openshift4-disconnected/blob/master/playbooks/docs/mirror_rhcos.md)

- [Mirror Tools](https://github.com/dmc5179/openshift4-disconnected/blob/master/playbooks/docs/mirror_tools.md)

- [Mirror OperatorHub Images](https://github.com/dmc5179/openshift4-disconnected/blob/master/playbooks/docs/mirror_operatorhub.md)

- [Mirror RPM Repositories](https://github.com/dmc5179/openshift4-disconnected/blob/master/playbooks/docs/mirror_rpms.md)

- [Mirror Additional Container Images](https://github.com/dmc5179/openshift4-disconnected/blob/master/playbooks/docs/mirror_additional_images.md)


### Air Gap Side

  This section covers setting up the infrastructure in the air gap environment and install the OpenShift 4 cluster

 - [Configure Infrastructure Variable File]

 - [Provision RPM Repo Mirror]

 - [Install Tools]

 - [Provision DNS]

 - [Generate Ignition Config]

 - [Launch Bootstrap Node]

 - [Launch Master Nodes]

 - [Launch Worker Nodes]

 - [Post Install]


### Miscellaneous

When installing in an emulator you may require an SSH tunnel to reach the web console.
The DNS names need to be configured because the cluster's pages will redirect so using
IPs directly won't work.

ssh -L 127.0.0.2:8443:10.0.106.42:443 -L 127.0.0.2:8080:10.0.106.42:80 ec2-user@proxyhost

Inside you local /etc/hosts:

127.0.0.2 console-openshift-console.apps.caas.redhatgovsa.io oauth-openshift.apps.caas.redhatgovsa.io

Now browse to https://console-openshift-console.apps.caas.redhatgovsa.io

### License


### Contributors

- [Dan Clark](https://github.com/dmc5179/) (maintainer)