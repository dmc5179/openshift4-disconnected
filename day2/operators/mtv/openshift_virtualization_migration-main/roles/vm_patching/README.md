<!-- STATIC CONTENT START
Use this section for adding additional content to the README
This will not be overwritten by Docsible -->
# 📃 Role overview

**DEPRECATED:** This role is deprecated here because it was moved to the `openshift_virtualization_ops` collection.

This role performs patching related activities for Virtual Machines.

<!-- STATIC CONTENT END -->
<!-- Everything below will be overwritten by Docsible -->
<!-- DOCSIBLE START -->
## vm_patching

```
Role belongs to infra/openshift_virtualization_migration
Namespace - infra
Collection - openshift_virtualization_migration
```

Description: Patching related activities for Virtual Machines.

| Field                | Value           |
|--------------------- |-----------------|
| Readme update        | 18/03/2025 |









### Vars

**These are variables with higher priority**
#### File: vars/main.yml


| Var          | Type         | Value       |
|--------------|--------------|-------------|
| [vm_patching_package_list](vars/main.yml#L3)   | str   | `*` |    


### Tasks


#### File: tasks/main.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| Running sudo dnf update | ansible.builtin.dnf | False |




## Playbook

```yml
---
- name: Test
  hosts: localhost
  remote_user: root
  roles:
    - vm_patching
...

```


## Author Information
Vinny Valdez

#### License

GPL-3.0-only

#### Minimum Ansible Version

2.15.0

#### Platforms

No platforms specified.
<!-- DOCSIBLE END -->