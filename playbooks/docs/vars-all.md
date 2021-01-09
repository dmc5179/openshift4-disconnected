# Set up of the all.yml variable file

This variable file contains the base settings used across many of the ansible roles in the repository

Copy the file 'playbooks/group_vars/all/infra/all.yml.example' to 'playbooks/group_vars/all/infra/all.yml'

| Variable                                     | Default                                             | Comments                                                                         |
| :---                                         | :---                                                | :---                                                                             |
| air_gapped                                   | true                                                | Air gap or disconnected environment                                              |
| platform                                     | 'none'                                              | none, aws, vmware                                                                |
| openshift_install                            | '/usr/local/bin/openshift-install'                  | Location of openshift-install binary                                             |
| openshift_client                             | '/usr/local/bin/oc'                                 | Location of oc binary                                                            |
| kubectl                                      | '/usr/local/bin/kubectl'                            | Location of kubectl binary                                                       |
| filetranspile                                | '/usr/local/bin/filetranspiler'                     | Location of filetranspiler binary                                                |
| fakeroots                                    | 'fakeroots'                                         | Location of the fakeroots directory for generating igniton configs for each node |
| rhcos_ver                                    | '4.5.2'                                             | OpenShift RHCOS Version Number                                                   |
| ocp_ver                                      | '4.5.4'                                             | OpenShift Version Number                                                         |
| arch                                         | 'x86_64'                                            | OpenShift Architecture                                                           |
| kube_ssl_enabled                             | false                                               | Enable SSL for kubernetes ansible tasks                                          |
| kubeconfig                                   | "{{ ansible_env.HOME }}/.kube/config"               | Location of kubeconfig when cluster is built                                     |
| master_count                                 | 3                                                   | Number of master nodes                                                           |
| worker_count                                 | 3                                                   | Number of worker nodes                                                           |
| fips_enabled                                 | false                                               | Enable FIPS                                                                      |
| ocp_cluster_publish                          | 'Internal'                                          | Publish load balancers external or internal                                      |
| ocp_base_domain                              | 'example.com'                                       | OpenShift base DNS name                                                          |
| ocp_cluster_name                             | 'caas'                                              | OpenShift cluster name                                                           |
| ssh_public_key_file                          | '{{ ansible_env.HOME }}/.ssh/id_rsa.pub'            | Location of ssh key to use for RHCOS nodes                                       |
| certificate_bundle                           | '/etc/pki/ca-trust/source/anchors/registry.crt'     | Location of SSL certificate for mirror registry                                  |
| mirror_base                                  | '/opt/openshift'                                    | Base directory for mirror bits, low and high side                                |
| mirror_registry                              | 'quay.example.com'                                  | DNS name of the mirror registry                                                  |
| mirror_registry_port                         | 5000                                                | Port for the mirror registry                                                     |
| mirror_transport                             | 'https'                                             | Protocol to use with the mirror registry                                         |
| ignition_configs                             | "{{ mirror_base }}/cluster"                         | Location                                                                         |
| local_pull_secret                            | '{{ ansible_env.HOME }}/Downloads/pull-secret.txt' | Pull secret for private registry                                                 |
| pull_secret                                  | '/opt/openshift/pull-secret.txt'                   | Pull secret for private registry                                                 |
| docker_registry_hostname                     | '{{ mirror_registry }}'                             | Hostname of the private registry (low side)                                      |
| network_mode                                 | static                                              | static or dhcpd network config for OCP nodes                                     |
| disk                                         | 'sda'                                               | Disk device to install RHCOS on each OCP node                                    |
