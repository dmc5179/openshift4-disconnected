Role Name
=========

A brief description of the role goes here.

Requirements
------------

Any pre-requisites that may not be covered by Ansible itself or the role should be mentioned here. For instance, if the role uses the EC2 module, it may be a good idea to mention in this section that the boto package is required.

Role Variables
--------------

A description of the settable variables for this role should go here, including any variables that are in defaults/main.yml, vars/main.yml, and any variables that can/should be set via parameters to the role. Any variables that are read from other roles and/or the global scope (ie. hostvars, group vars, etc.) should be mentioned here as well.

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
<!-- DOCSIBLE START -->
## vm_mac_address

```
Role belongs to infra/openshift_virtualization_migration
Namespace - infra
Collection - openshift_virtualization_migration
```

Description: Management of Virtual Machine MAC Addresses.

| Field                | Value           |
|--------------------- |-----------------|
| Readme update        | 18/06/2025 |






### Defaults

**These are static variables with lower priority**

#### File: defaults/main.yml

| Var          | Type         | Value       |Choices    |Required    | Title       |
|--------------|--------------|-------------|-------------|-------------|-------------|
| [vm_mac_address_request](defaults/main.yml#L7)   | list   | `[]` |  n/a  |   True  |  MAC Address Request |
| [vm_mac_address_openshift_host](defaults/main.yml#L17)   | str   | `{{ openshift_host }}` |  n/a  |   True  |  OpenShift Host |
| [vm_mac_address_api_key](defaults/main.yml#L21)   | str   | `{{ openshift_api_key }}` |  n/a  |   True  |  OpenShift API Key |
| [vm_mac_address_openshift_verify_ssl](defaults/main.yml#L25)   | str   | `{{ openshift_verify_ssl }}` |  n/a  |   True  |  Verify SSL Certificate |
| [vm_mac_address_kubevirt_api_version](defaults/main.yml#L29)   | str   | `kubevirt.io/v1` |  n/a  |   True  |  KubeVirt API Version |
<summary><b>🖇️ Full descriptions for vars in defaults/main.yml</b></summary>
<br>
<b>vm_mac_address_request:</b> List of MAC Address Requests
<br>
<b>vm_mac_address_openshift_host:</b> OpenShift Host
<br>
<b>vm_mac_address_api_key:</b> OpenShift API Key
<br>
<b>vm_mac_address_openshift_verify_ssl:</b> Verify SSL Certificate
<br>
<b>vm_mac_address_kubevirt_api_version:</b> KubeVirt API Version
<br>
<br>





### Tasks


#### File: tasks/_compute_patch.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| _compute_patch ¦ Verify Valid MAC Address Provided | ansible.builtin.assert | False |
| _compute_patch ¦ Locate Interface Index | ansible.builtin.set_fact | False |
| _compute_patch ¦ Create Patch Item | ansible.builtin.set_fact | True |

#### File: tasks/_process_vm.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| _process_vm ¦ Initialize Variables | ansible.builtin.set_fact | False |
| _process_vm ¦ Query for Virtual Machine | kubernetes.core.k8s_info | False |
| _process_vm ¦ Verify Virtual Machine Exists | ansible.builtin.assert | False |
| _process_vm ¦ Compute Patch for Interface | ansible.builtin.include_tasks | True |
| _process_vm ¦ Update VM MAC Address | kubernetes.core.k8s_json_patch | True |

#### File: tasks/main.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| Verify vm_mac_address_request Variable Provided | ansible.builtin.assert | False |
| Verify Required Properties Provided | ansible.builtin.assert | False |
| Process MAC Address VM | ansible.builtin.include_tasks | False |




## Playbook

```yml
---
- name: Test
  hosts: localhost
  remote_user: root
  roles:
    - vm_mac_address
...

```


## Author Information
Andrew Block

#### License

GPL-3.0-only

#### Minimum Ansible Version

2.15.0

#### Platforms

No platforms specified.
<!-- DOCSIBLE END -->