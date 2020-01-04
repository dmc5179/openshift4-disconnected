# OpenShift 4 Disconnected
**Table of Contents**
- [Purpose](#Purpose)
- [Getting Started](#Getting-Started)
- [Miscellaneous](#Miscellaneous)

### Purpose 
This repository contains scripts and tooling for deploying an OpenShift 4.2 cluster in an air-gapped environment

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
