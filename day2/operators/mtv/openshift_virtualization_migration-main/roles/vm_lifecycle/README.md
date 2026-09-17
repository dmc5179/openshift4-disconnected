<!-- STATIC CONTENT START
Use this section for adding additional content to the README
This will not be overwritten by Docsible -->
# 📃 Role overview

**DEPRECATED:** This role is deprecated here because it was moved to the `openshift_virtualization_ops` collection.

This role performs and manages the lifecycle operations (start/stop/restart) of Virtual Machines.

<!-- STATIC CONTENT END -->
<!-- Everything below will be overwritten by Docsible -->
<!-- DOCSIBLE START -->
## vm_lifecycle

```
Role belongs to infra/openshift_virtualization_migration
Namespace - infra
Collection - openshift_virtualization_migration
```

Description: Management of the lifecycle activities of Virtual Machines.

| Field                | Value           |
|--------------------- |-----------------|
| Readme update        | 18/03/2025 |






### Defaults

**These are static variables with lower priority**

#### File: defaults/main.yml

| Var          | Type         | Value       |Choices    |Required    | Title       |
|--------------|--------------|-------------|-------------|-------------|-------------|
| [vm_lifecycle_vm_operations_request](defaults/main.yml#L6)   | list   | `[]` |  n/a  |   True  |  List of VMs to perform lifecycle operations |
| [vm_lifecycle_kubevirt_api_version](defaults/main.yml#L17)   | str   | `kubevirt.io/v1` |  n/a  |   True  |  KubeVirt API Version |
| [vm_lifecycle_openshift_host](defaults/main.yml#L21)   | str   | `{{ openshift_host }}` |  n/a  |   True  |  OpenShift host |
| [vm_lifecycle_openshift_api_key](defaults/main.yml#L25)   | str   | `{{ openshift_api_key }}` |  n/a  |   True  |  OpenShift API Key |
| [vm_lifecycle_openshift_verify_ssl](defaults/main.yml#L29)   | str   | `{{ openshift_verify_ssl }}` |  n/a  |   True  |  Enable SSL Verification |
| [vm_lifecycle_verify_retries](defaults/main.yml#L34)   | int   | `100` |  n/a  |   True  |  Number of retries |
| [vm_lifecycle_verify_delay](defaults/main.yml#L38)   | int   | `10` |  n/a  |   True  |  Number of delays |
<summary><b>🖇️ Full descriptions for vars in defaults/main.yml</b></summary>
<br>
<b>vm_lifecycle_vm_operations_request:</b> List of VM Lifecycle Operation requests
<br>
<b>vm_lifecycle_kubevirt_api_version:</b> KubeVirt API Version
<br>
<b>vm_lifecycle_openshift_host:</b> OpenShift host
<br>
<b>vm_lifecycle_openshift_api_key:</b> OpenShift API Key
<br>
<b>vm_lifecycle_openshift_verify_ssl:</b> Variable to enable SSL verification
<br>
<b>vm_lifecycle_verify_retries:</b> Number of retries
<br>
<b>vm_lifecycle_verify_delay:</b> Number of delays
<br>
<br>


### Vars

**These are variables with higher priority**
#### File: vars/main.yml


| Var          | Type         | Value       |
|--------------|--------------|-------------|
| [vm_lifecycle_valid_vm_operations](vars/main.yml#L2)   | dict   | `{'start': {'endpoint': 'start', 'status': 'Running', 'ready': True}, 'stop': {'endpoint': 'stop', 'status': 'Stopped'}, 'restart': {'endpoint': 'restart', 'status': 'Running', 'ready': True, 'idempotent': True}}` |    


### Tasks


#### File: tasks/_collect_vms.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| _collect_vms ¦ Verify Valid VM Operation | ansible.builtin.assert | False |
| _collect_vms ¦ Verify Namespace Provided When Name Specified | ansible.builtin.assert | True |
| _collect_vms ¦ Query VM's Without Label Selector | block | True |
| _collect_vms ¦ Query VM's (Without Label Selector) | kubernetes.core.k8s_info | False |
| _collect_vms ¦ Add VM's (Without Label Selector) | ansible.builtin.set_fact | True |
| _collect_vms ¦ Query VM's Using Label Selector | block | True |
| _collect_vms ¦ Query VM's (With Label Selector) | kubernetes.core.k8s_info | False |
| _collect_vms ¦ Add VM's (With Label Selector) | ansible.builtin.set_fact | True |

#### File: tasks/_perform_operation.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| _perform_operation ¦ Perform VM Operation | ansible.builtin.uri | False |

#### File: tasks/_verify_operation.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| _verify_operation ¦ Verify VMs | kubernetes.core.k8s_info | False |

#### File: tasks/vm_operations.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| vm_operations ¦ Verify OpenShift Connectivity Details Provided | ansible.builtin.assert | False |
| vm_operations ¦ Initialize Variables | ansible.builtin.set_fact | False |
| vm_operations ¦ Collect VM's | ansible.builtin.include_tasks | False |
| vm_operations ¦ Print VM's | ansible.builtin.debug | False |
| vm_operations ¦ Perform VM Operations | ansible.builtin.include_tasks | False |
| vm_operations ¦ Verify VMs | ansible.builtin.include_tasks | False |




## Playbook

```yml
---
- name: Test
  hosts: localhost
  remote_user: root
  roles:
    - vm_lifecycle
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