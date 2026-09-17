<!-- STATIC CONTENT START
Use this section for adding additional content to the README
This will not be overwritten by Docsible -->
# 📃 Role overview

This role performs network management in two modes: Manual and Automatic. It performs tasks that include gathering network information in the vCenter environment, migrate the Port Groups by creating NetworkAttachementDefinitions (NAD), and migrate distributed switches by creating NodeNetworkConfigurationPolicy (NNCP).
<!-- STATIC CONTENT END -->
<!-- Everything below will be overwritten by Docsible -->
<!-- DOCSIBLE START -->
## network_mgmt

```
Role belongs to infra/openshift_virtualization_migration
Namespace - infra
Collection - openshift_virtualization_migration
```

Description: Management of network related components.

| Field                | Value           |
|--------------------- |-----------------|
| Readme update        | 18/03/2025 |






### Defaults

**These are static variables with lower priority**

#### File: defaults/main.yml

| Var          | Type         | Value       |Choices    |Required    | Title       |
|--------------|--------------|-------------|-------------|-------------|-------------|
| [network_mgmt_openshift_node_network_ports](defaults/main.yml#L5)   | list   | `[]` |  n/a  |   True  |  OpenShift Node Network Ports |
| [network_mgmt_port_is_existing_bond](defaults/main.yml#L10)   | bool   | `False` |  n/a  |   True  |  Define Bond |
| [network_mgmt_vcenter_dvswitch](defaults/main.yml#L16)   | str   | `` |  n/a  |   True  |  vCenter DVSwitch |
| [network_mgmt_vcenter_datacenter](defaults/main.yml#L21)   | str   | `` |  n/a  |   True  |  vCenter Data Center |
| [network_mgmt_openshift_network_bridge_mode](defaults/main.yml#L26)   | str   | `linux-bridge` |  n/a  |   True  |  OpenShift Network Bridge Mode |
| [network_mgmt_use_default_ovn_bridge](defaults/main.yml#L31)   | bool   | `False` |  n/a  |   True  |  OVN Bridge |
| [network_mgmt_openshift_network_bond_mode](defaults/main.yml#L40)   | str   | `802.3ad` |  n/a  |   True  |  OpenShift Network Bond Mode |
| [network_mgmt_openshift_network_supported_bond_modes](defaults/main.yml#L46)   | list   | `['802.3ad', 'active-backup', 'balance-xor']` |  n/a  |   True  |  Supported Bond Modes |
| [network_mgmt_nncp_max_unavailable](defaults/main.yml#L54)   | int   | `3` |  n/a  |   True  |  NNCP Max Unavailability |
| [network_mgmt_nncp_nodeselector](defaults/main.yml#L62)   | dict   | `{'node-role.kubernetes.io/worker': ''}` |  n/a  |   True  |  NNCP NodeSelector |
| [network_mgmt_nncp_name_prefix](defaults/main.yml#L68)   | str   | `vs-` |  n/a  |   True  |  NNCP Name Prefix |
| [network_mgmt_nad_namespace](defaults/main.yml#L73)   | str   | `default` |  n/a  |   True  |  NAD Namespace |
| [network_mgmt_nad_auto_bridge_name](defaults/main.yml#L78)   | str   | `` |  n/a  |   n/a  |  n/a |
| [network_mgmt_nad_name_prefix](defaults/main.yml#L85)   | str   | `net-` |  n/a  |   True  |  NAD Name Prefix |
| [network_mgmt_manual_bond_name](defaults/main.yml#L90)   | str   | `` |  n/a  |   True  |  Bond Name in Manual Mode |
| [network_mgmt_manual_bridge_name](defaults/main.yml#L95)   | str   | `vm-bridge` |  n/a  |   True  |  Bridge Name in Manual Mode |
| [network_mgmt_manual_localnet_name](defaults/main.yml#L100)   | str   | `` |  n/a  |   True  |  Local Network Name in Manual Mode |
| [network_mgmt_manual_nad_list](defaults/main.yml#L105)   | list   | `[]` |  n/a  |   True  |  NAD List in Manual Mode |
<summary><b>🖇️ Full descriptions for vars in defaults/main.yml</b></summary>
<br>
<b>network_mgmt_openshift_node_network_ports:</b> List of Node Network Ports
<br>
<b>network_mgmt_port_is_existing_bond:</b> Boolean value to check if a bond is defined
<br>
<b>network_mgmt_vcenter_dvswitch:</b> vCenter Distributed Switch
<br>
<b>network_mgmt_vcenter_datacenter:</b> vCenter Data Center name
<br>
<b>network_mgmt_openshift_network_bridge_mode:</b> OpenShift Network Bridge Mode
<br>
<b>network_mgmt_use_default_ovn_bridge:</b> Boolean value defines usage of OVN bridge
<br>
<b>network_mgmt_openshift_network_bond_mode:</b> OpenShift Network Bond Mode
<br>
<b>network_mgmt_openshift_network_supported_bond_modes:</b> List of supported bond modes
<br>
<b>network_mgmt_nncp_max_unavailable:</b> Maximum number of times NNCP can be unavailable
<br>
<b>network_mgmt_nncp_nodeselector:</b> NNCP NodeSelector on the OpenShift cluster
<br>
<b>network_mgmt_nncp_name_prefix:</b> NNCP Name Prefix
<br>
<b>network_mgmt_nad_namespace:</b> NAD Namespace
<br>
<b>network_mgmt_nad_name_prefix:</b> NAD Name Prefix
<br>
<b>network_mgmt_manual_bond_name:</b> Bond Name in Manual Mode
<br>
<b>network_mgmt_manual_bridge_name:</b> Bridge Name in Manual Mode
<br>
<b>network_mgmt_manual_localnet_name:</b> Local Network Name in Manual Mode
<br>
<b>network_mgmt_manual_nad_list:</b> NAD List in Manual Mode
<br>
<br>





### Tasks


#### File: tasks/automatic.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| automatic ¦ Include tasks from gather_networks.yml | ansible.builtin.include_tasks | False |
| automatic ¦ Set the switches and portgroups to migrate | ansible.builtin.set_fact | False |
| automatic ¦ Include tasks from automatic_nncp.yml | ansible.builtin.include_tasks | True |
| automatic ¦ Include tasks from automatic_nad.yml | ansible.builtin.include_tasks | True |

#### File: tasks/automatic_nad.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| automatic_nad ¦ Include tasks from create_nad.yml | ansible.builtin.include_tasks | False |

#### File: tasks/automatic_nncp.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| automatic_nncp ¦ Validate supported bonding mode | ansible.builtin.assert | True |
| automatic_nncp ¦ Include tasks from create_nncp.yml | ansible.builtin.include_tasks | False |

#### File: tasks/create_nad.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| create_nad ¦ "DEBUG nad Template" | ansible.builtin.debug | True |
| create_nad ¦ Apply NetworkAttachmentDefinitions | redhat.openshift.k8s | True |

#### File: tasks/create_nncp.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| create_nncp ¦ DEBUG nncp Template | ansible.builtin.debug | True |
| create_nncp ¦ Apply NodeNetworkConfigurationPolicy | redhat.openshift.k8s | True |

#### File: tasks/gather_networks.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| gather_networks ¦ Gather all registered dvswitch | community.vmware.vmware_dvswitch_info | False |
| gather_networks ¦ Get info for all dVSwitch Port Groups | community.vmware.vmware_dvs_portgroup_info | False |

#### File: tasks/main.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| Use automatic mode | ansible.builtin.include_tasks | True |
| Use manual mode | ansible.builtin.include_tasks | True |

#### File: tasks/manual.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| manual ¦ Validate network_mgmt_manual_nad_list | ansible.builtin.assert | False |
| manual ¦ Validate supported bonding mode if also creating bond | ansible.builtin.assert | True |
| manual ¦ Validate ovs-bridge mode | ansible.builtin.assert | True |
| manual ¦ Validate linux-bridge | ansible.builtin.assert | False |
| manual ¦ Apply NodeNetworkConfigurationPolicy | redhat.openshift.k8s | True |
| manual ¦ Validate access port | ansible.builtin.assert | True |
| manual ¦ Validate trunk ports | ansible.builtin.assert | True |
| manual ¦ Apply NetworkAttachmentDefinitions | redhat.openshift.k8s | False |




## Playbook

```yml
---
- name: Test
  hosts: localhost
  remote_user: root
  roles:
    - network_mgmt
...

```


## Author Information
Kyle Button

#### License

GPL-3.0-only

#### Minimum Ansible Version

2.15.0

#### Platforms

No platforms specified.
<!-- DOCSIBLE END -->