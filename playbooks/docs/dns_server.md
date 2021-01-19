# Install and Configure a DNS Server

## Current Supported Versions

### BIND

 - Copy the file 'group_vars/all/software/dns_server.yaml.example' to 'group_vars/all/software/dns_server.yaml'
 - Edit The dns_server.yaml variable file based on the role documentation here
[BIND Role Variables](https://github.com/dmc5179/openshift4-disconnected/blob/master/playbooks/roles/install_bind/README.md)

 - Run the Ansible Playbook to install and configure BIND
 ```
 ansible_playbook dns_server.yaml
 ```

## Future Support

### IPA
