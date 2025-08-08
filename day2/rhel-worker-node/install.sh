#!/bin/bash

cd /usr/share/ansible/openshift-ansible

ansible-playbook -i /path/to/hosts/file playbooks/scaleup.yml
