<!-- STATIC CONTENT START
Use this section for adding additional content to the README
This will not be overwritten by Docsible -->
# 📃 Role overview

**DEPRECATED:** This role is deprecated here because it was moved to the `openshift_virtualization_ops` collection.

This role performs hot plugging in a virtual machine.

<!-- STATIC CONTENT END -->
<!-- Everything below will be overwritten by Docsible -->
<!-- DOCSIBLE START -->
## vm_hot_plug

```
Role belongs to infra/openshift_virtualization_migration
Namespace - infra
Collection - openshift_virtualization_migration
```

Description: Hot Plug Virtual Machine resources.

| Field                | Value           |
|--------------------- |-----------------|
| Readme update        | 18/03/2025 |






### Defaults

**These are static variables with lower priority**

#### File: defaults/main.yml

| Var          | Type         | Value       |Choices    |Required    | Title       |
|--------------|--------------|-------------|-------------|-------------|-------------|
| [vm_hot_plug_request](defaults/main.yml#L7)   | list   | `[]` |  n/a  |   True  |  Hot Plug Requests |
| [vm_hot_plug_openshift_host](defaults/main.yml#L26)   | str   | `{{ openshift_host }}` |  n/a  |   True  |  OpenShift Host |
| [vm_hot_plug_api_key](defaults/main.yml#L30)   | str   | `{{ openshift_api_key }}` |  n/a  |   True  |  OpenShift API Key |
| [vm_hot_plug_openshift_verify_ssl](defaults/main.yml#L34)   | str   | `{{ openshift_verify_ssl }}` |  n/a  |   True  |  Verify SSL Certificate |
| [vm_hot_plug_kubevirt_api_version](defaults/main.yml#L38)   | str   | `kubevirt.io/v1` |  n/a  |   True  |  KubeVirt API Version |
<summary><b>🖇️ Full descriptions for vars in defaults/main.yml</b></summary>
<br>
<b>vm_hot_plug_request:</b> List of Hot Plug Requests
<br>
<b>vm_hot_plug_openshift_host:</b> OpenShift Host
<br>
<b>vm_hot_plug_api_key:</b> OpenShift API Key
<br>
<b>vm_hot_plug_openshift_verify_ssl:</b> Verify SSL Certificate
<br>
<b>vm_hot_plug_kubevirt_api_version:</b> KubeVirt API Version
<br>
<br>





### Tasks


#### File: tasks/_compute.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| _compute ¦ Verify Instance Type exists on VM | ansible.builtin.assert | True |
| _compute ¦ Verify Instance Type does not exist on VM | ansible.builtin.assert | True |
| _compute ¦ Patch VM with Compute Modifications | kubernetes.core.k8s_json_patch | False |

#### File: tasks/_process_vm.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| _process_vm ¦ Process Compute Hot Plug | ansible.builtin.include_tasks | True |
| _process_vm ¦ Process Compute Hot Plug | ansible.builtin.include_tasks | True |
| _process_vm ¦ Manage restarting VM | block | True |
| _process_vm ¦ Query VM for Updated Configuration | kubernetes.core.k8s_info | False |
| _process_vm ¦ Restart the machine | block | True |
| _process_vm ¦ Restart the VirtualMachine | ansible.builtin.include_role | False |
| _process_vm ¦ Verify the VirtualMachine restarted | ansible.builtin.include_role | False |

#### File: tasks/_storage.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| _storage ¦ Perform VM Storage Operation | ansible.builtin.uri | True |

#### File: tasks/main.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| Initialize Variables | ansible.builtin.set_fact | False |
| Invoke Collect VM Role | ansible.builtin.include_role | False |
| Process Hot Plug VM | ansible.builtin.include_tasks | False |




## Playbook

```yml
---
- name: Test
  hosts: localhost
  remote_user: root
  roles:
    - vm_hot_plug
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