# OpenShift 4 Disconnected

**Table of Contents**
  - [Purpose](#Purpose)
  - [Requirements](#Requirements)
  - [Dependencies](#Dependencies)
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

### Getting Started

Step 1: Create a docker registry to host the mirrored images

Step 2: Mirror the images into your new registry

Step 3: Create a DNS server in your air-gapped environment

Step 4: Install the required OpenShift clients and tools

Step 5: Generate Igntion Configs

Step 6: Stage Ignition Configs

Step 7: Launch Bootstrap Node

Step 8: Launch Master Nodes

Step 9: Launch Worker Nodes

Step 10: Post Install


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