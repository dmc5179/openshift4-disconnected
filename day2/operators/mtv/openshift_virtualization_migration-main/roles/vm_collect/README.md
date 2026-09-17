<!-- STATIC CONTENT START
Use this section for adding additional content to the README
This will not be overwritten by Docsible -->
# 📃 Role overview

**DEPRECATED:** This role is deprecated here because it was moved to the `openshift_virtualization_ops` collection.

<!-- STATIC CONTENT END -->
<!-- Everything below will be overwritten by Docsible -->
<!-- DOCSIBLE START -->
## vm_collect

```
Role belongs to infra/openshift_virtualization_migration
Namespace - infra
Collection - openshift_virtualization_migration
```

Description: Collection of Migration Toolkit for Virtualization inventory information.

| Field                | Value           |
|--------------------- |-----------------|
| Readme update        | 18/03/2025 |






### Defaults

**These are static variables with lower priority**

#### File: defaults/main.yml

| Var          | Type         | Value       |Choices    |Required    | Title       |
|--------------|--------------|-------------|-------------|-------------|-------------|
| [vm_collect_obj_default_api_version](defaults/main.yml#L4)   | str   | `kubevirt.io/v1` |  n/a  |   n/a  |  n/a |
| [vm_collect_obj_default_kind](defaults/main.yml#L5)   | str   | `VirtualMachine` |  n/a  |   n/a  |  n/a |





### Tasks


#### File: tasks/main.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| Verify Request Variable Provided | ansible.builtin.assert | False |
| Verify Valid Result Variable Provided | ansible.builtin.assert | False |
| Verify Namespace Provided When Name Specified | ansible.builtin.assert | True |
| Query Without Label Selector - {{ vm_collect_obj ¦ default(vm_collect_obj_default_kind) }} | block | True |
| Query Without Label Selector {{ vm_collect_obj ¦ default(vm_collect_obj_default_kind) }} | kubernetes.core.k8s_info | False |
| Add (Without Label Selector) {{ vm_collect_obj ¦ default(vm_collect_obj_default_kind) }} | ansible.builtin.set_fact | True |
| Query Using Label Selector - {{ vm_backup_restore_collect_obj ¦ default(collect_obj_default_kind) }} | block | True |
| Query (With Label Selector) - {{ vm_collect_obj ¦ default(vm_collect_obj_default_kind) }} | kubernetes.core.k8s_info | False |
| Add (With Label Selector) - {{ vm_collect_obj ¦ default(vm_collect_obj_default_kind) }} | ansible.builtin.set_fact | True |




## Playbook

```yml
---
- name: Test
  hosts: localhost
  remote_user: root
  roles:
    - vm_collect
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