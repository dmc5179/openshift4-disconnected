<!-- STATIC CONTENT START
Use this section for adding additional content to the README
This will not be overwritten by Docsible -->
# 📃 Role overview


<!-- STATIC CONTENT END -->
<!-- Everything below will be overwritten by Docsible -->
<!-- DOCSIBLE START -->
## mtv_management

```
Role belongs to infra/openshift_virtualization_migration
Namespace - infra
Collection - openshift_virtualization_migration
```

Description: Management of the Migration Toolkit for Virtualization (MTV).

| Field                | Value           |
|--------------------- |-----------------|
| Readme update        | 18/03/2025 |






### Defaults

**These are static variables with lower priority**

#### File: defaults/main.yml

| Var          | Type         | Value       |Choices    |Required    | Title       |
|--------------|--------------|-------------|-------------|-------------|-------------|
| [mtv_management_namespace](defaults/main.yml#L7)   | str   | `openshift-mtv` |  n/a  |   True  |  Default MTV Namespace |
| [mtv_management_provider_namespace](defaults/main.yml#L11)   | str   | `{{ mtv_management_namespace }}` |  n/a  |   True  |  MTV Provider Namespace |
| [mtv_management_migration_namespace](defaults/main.yml#L15)   | str   | `{{ mtv_management_namespace }}` |  n/a  |   True  |  MTV Migration Namespace |
| [mtv_management_map_providers](defaults/main.yml#L21)   | bool   | `True` |  n/a  |   False  |  Map Providers Boolean |
| [mtv_management_map_storage](defaults/main.yml#L25)   | bool   | `True` |  n/a  |   False  |  Map Storage Boolean |
| [mtv_management_map_networks](defaults/main.yml#L29)   | bool   | `True` |  n/a  |   False  |  Map Networks Boolean |
| [mtv_management_inventory_url](defaults/main.yml#L35)   | str   | `` |  n/a  |   False  |  Inventory URL |
| [mtv_management_inventory_route_name](defaults/main.yml#L39)   | str   | `forklift-inventory` |  n/a  |   True  |  Inventory Route Name |
| [mtv_management_inventory_retrieval_method](defaults/main.yml#L45)   | str   | `exec` |  n/a  |   True  |  n/a |
| [mtv_management_migration_targets](defaults/main.yml#L51)   | list   | `[]` |  n/a  |   False  |  MTV Migration Targets |
| [mtv_management_vmware_provider_default_name](defaults/main.yml#L72)   | str   | `vmware` |  n/a  |   True  |  MTV VMware Provider Name |
| [mtv_management_vmware_provider_default_sdk_endpoint](defaults/main.yml#L76)   | str   | `/sdk` |  n/a  |   True  |  MTV SDK Endpoint |
| [mtv_management_ovirt_provider_default_name](defaults/main.yml#L80)   | str   | `ovirt` |  n/a  |   True  |  MTV Ovirt Provider Name |
| [mtv_management_ovirt_provider_default_sdk_endpoint](defaults/main.yml#L84)   | str   | `/ovirt-engine/api` |  n/a  |   True  |  MTV SDK Endpoint |
| [mtv_management_vmware_provider_insecure_skip_tls_verify](defaults/main.yml#L88)   | bool   | `True` |  n/a  |   False  |  MTV Skip TLS |
| [mtv_management_default_storage_class](defaults/main.yml#L92)   | str   | `` |  n/a  |   False  |  MTV Default StorageClass |
| [mtv_management_source_target](defaults/main.yml#L98)   | str   | `vmware` |  n/a  |   True  |  MTV Source Target |
| [mtv_management_destination_target](defaults/main.yml#L102)   | str   | `host` |  n/a  |   True  |  MTV Destination Target |
| [mtv_management_nad_source_portgroup_annotation](defaults/main.yml#L107)   | str   | `infra.openshift-virtualization-migration/source-portgroup` |  n/a  |   True  |  MTV NAD Source Portgroup Annotation |
| [mtv_management_vmware_vddk_secret_name](defaults/main.yml#L112)   | str   | `{{ mtv_management_source_target }}-vddk` |  n/a  |   True  |  VDDK Secret Name |
| [mtv_management_vmware_vddk_init_image](defaults/main.yml#L117)   | str   | `` |  n/a  |   False  |  MTV VDDK Image |
| [mtv_management_vmware_vddk_init_image_username](defaults/main.yml#L122)   | str   | `` |  n/a  |   False  |  VDDK Image Username |
| [mtv_management_vmware_vddk_init_image_password](defaults/main.yml#L127)   | str   | `` |  n/a  |   False  |  VDDK Image Password |
| [mtv_management_vmware_vddk_init_image_credentials_secret](defaults/main.yml#L132)   | str   | `` |  n/a  |   False  |  VDDK Credentials Secret |
| [mtv_management_vmware_vddk_init_image_service_account](defaults/main.yml#L137)   | str   | `default` |  n/a  |   False  |  VDDK Service Account |
| [mtv_management_storage_map_overrides](defaults/main.yml#L143)   | list   | `[]` |  n/a  |   False  |  MTV Storage Map Override |
| [mtv_management_network_map_overrides](defaults/main.yml#L153)   | list   | `[]` |  n/a  |   False  |  MTV Network Map Overrides |
<summary><b>🖇️ Full descriptions for vars in defaults/main.yml</b></summary>
<br>
<b>mtv_management_namespace:</b> The default namespace to use if not specified
<br>
<b>mtv_management_provider_namespace:</b> The provider namespace to use
<br>
<b>mtv_management_migration_namespace:</b> The migration namespace to use
<br>
<b>mtv_management_map_providers:</b> Determines whether to include the mtv_providers task file
<br>
<b>mtv_management_map_storage:</b> Determines whether to include the mtv_maps task file
<br>
<b>mtv_management_map_networks:</b> Determines whether to include the mtv_maps task file
<br>
<b>mtv_management_inventory_url:</b> Inventory URL
<br>
<b>mtv_management_inventory_route_name:</b> Inventory Route Name
<br>
<b>mtv_management_vmware_provider_default_name:</b> Default name for VMware provider
<br>
<b>mtv_management_vmware_provider_default_sdk_endpoint:</b> VMware provider endpoint
<br>
<b>mtv_management_ovirt_provider_default_name:</b> Default name for Ovirt provider
<br>
<b>mtv_management_ovirt_provider_default_sdk_endpoint:</b> Ovirt provider endpoint
<br>
<b>mtv_management_vmware_provider_insecure_skip_tls_verify:</b> Whether to skip TLS verify
<br>
<b>mtv_management_default_storage_class:</b> The StorageClass to use by default
<br>
<b>mtv_management_source_target:</b> Source target
<br>
<b>mtv_management_destination_target:</b> Destination target
<br>
<b>mtv_management_nad_source_portgroup_annotation:</b> The annotation to use for the Network Attachment Definition
<br>
<b>mtv_management_vmware_vddk_secret_name:</b> Name of the Created Secret for VDDK Credentials
<br>
<b>mtv_management_vmware_vddk_init_image:</b> The image to use for VDDK
<br>
<b>mtv_management_vmware_vddk_init_image_username:</b> Username for the VDDK Image
<br>
<b>mtv_management_vmware_vddk_init_image_password:</b> Password for the VDDK Image
<br>
<b>mtv_management_vmware_vddk_init_image_credentials_secret:</b> Secret Containing Credentials for the VDDK Image
<br>
<b>mtv_management_vmware_vddk_init_image_service_account:</b> Service Account to Associate the VDDK Init Image Pull Secret
<br>
<b>mtv_management_storage_map_overrides:</b> Overrides for the storage map
<br>
<b>mtv_management_network_map_overrides:</b> Overrides for the network map
<br>
<br>





### Tasks


#### File: tasks/_mtv_network_map.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| _mtv_network_map ¦ Initialize data structures | ansible.builtin.set_fact | False |
| _mtv_network_map ¦ Verify Network Map Overrides do not contain both includes and excludes | ansible.builtin.fail | True |
| _mtv_network_map ¦ Query for VMWare Networks from Source Provider | ansible.builtin.include_tasks | True |
| _mtv_network_map ¦ Query for Ovirt Networks from Source Provider | ansible.builtin.include_tasks | True |
| _mtv_network_map ¦ Query for NetworkAttachmentDefinitions from Destination Provider | ansible.builtin.include_tasks | False |
| _mtv_network_map ¦ Process VMware Networks | ansible.builtin.include_tasks | True |
| _mtv_network_map ¦ Process Ovirt Networks | ansible.builtin.include_tasks | True |
| _mtv_network_map ¦ Template NetworkMap Map | ansible.builtin.set_fact | False |
| _mtv_network_map ¦ Create Network Map | redhat.openshift.k8s | False |

#### File: tasks/_mtv_network_map_process_network.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| _mtv_network_map_process_network ¦ Set VMware NetworkMap Variables | ansible.builtin.set_fact | True |
| _mtv_network_map_process_network ¦ Set Ovirt NetworkMap Variables | ansible.builtin.set_fact | True |
| _mtv_network_map_process_network ¦ Locate VMware NetworkAttachmentDefinition | ansible.builtin.set_fact | True |
| _mtv_network_map_process_network ¦ Locate Ovirt NetworkAttachmentDefinition | ansible.builtin.set_fact | True |
| _mtv_network_map_process_network ¦ Validate Found VMware NetworkAttachmentDefinitions | ansible.builtin.assert | True |
| _mtv_network_map_process_network ¦ Validate Found Ovirt NetworkAttachmentDefinitions | ansible.builtin.assert | True |
| _mtv_network_map_process_network ¦ Template NetworkMap Map | ansible.builtin.set_fact | False |
| _mtv_network_map_process_network ¦ Add VMWare NetworkMaps Map to Dict | ansible.builtin.set_fact | True |
| _mtv_network_map_process_network ¦ Add Ovirt NetworkMaps Map to Dict | ansible.builtin.set_fact | True |

#### File: tasks/_mtv_provider_ovirt.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| _mtv_provider_ovirt ¦ Verify credential name provided when more than one credential specified | ansible.builtin.assert | True |
| _mtv_provider_ovirt ¦ Set provider name | ansible.builtin.set_fact | False |
| _mtv_provider_ovirt ¦ Validate required Ovirt provider Properties | ansible.builtin.assert | False |
| _mtv_provider_ovirt ¦ Set Ovirt Provider URL | ansible.builtin.set_fact | False |
| _mtv_provider_ovirt ¦ MTV Certificate | block | True |
| _mtv_provider_ovirt ¦ Retrieve Remote Ovirt Provider Certificate | community.crypto.get_certificate | False |
| _mtv_provider_ovirt ¦ Set Ovirt Provider Certificate | ansible.builtin.set_fact | False |
| _mtv_provider_ovirt ¦ Set Provider Secret Name/Namespace (Configuration) | ansible.builtin.set_fact | True |
| _mtv_provider_ovirt ¦ Configure Provider Secret | block | True |
| _mtv_provider_ovirt ¦ Set Provider Secret Name/Namespace (Generated) | ansible.builtin.set_fact | True |
| _mtv_provider_ovirt ¦ Create Ovirt credentials secret | redhat.openshift.k8s | True |
| _mtv_provider_ovirt ¦ Create Ovirt Provider resource | redhat.openshift.k8s | False |

#### File: tasks/_mtv_provider_vmware.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| _mtv_provider_vmware ¦ Verify credential name provided when more than one credential specified | ansible.builtin.assert | True |
| _mtv_provider_vmware ¦ Set provider name | ansible.builtin.set_fact | False |
| _mtv_provider_vmware ¦ Validate required VMware provider Properties | ansible.builtin.assert | False |
| _mtv_provider_vmware ¦ Set VMware Provider URL | ansible.builtin.set_fact | False |
| _mtv_provider_vmware ¦ MTV Certificate | block | True |
| _mtv_provider_vmware ¦ Retrieve Remote VMware Provider Certificate | community.crypto.get_certificate | False |
| _mtv_provider_vmware ¦ Set VMware Provider Certificate | ansible.builtin.set_fact | False |
| _mtv_provider_vmware ¦ Set Provider Secret Name/Namespace (Configuration) | ansible.builtin.set_fact | True |
| _mtv_provider_vmware ¦ Configure Provider Secret | block | True |
| _mtv_provider_vmware ¦ Set Provider Secret Name/Namespace (Generated) | ansible.builtin.set_fact | True |
| _mtv_provider_vmware ¦ Create VMware credentials secret | redhat.openshift.k8s | True |
| _mtv_provider_vmware ¦ Create VMware Provider resource | redhat.openshift.k8s | False |

#### File: tasks/_mtv_storage_map.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| _mtv_storage_map ¦ Initialize data structures | ansible.builtin.set_fact | False |
| _mtv_storage_map ¦ Verify Storage Map Overrides do not contain both includes and excludes | ansible.builtin.fail | True |
| _mtv_storage_map ¦ Query for Storage Classes from Destination Provider | ansible.builtin.include_tasks | False |
| _mtv_storage_map ¦ Determine Destination Storage Class | ansible.builtin.set_fact | True |
| _mtv_storage_map ¦ Query for Datastores from Destination Provider | ansible.builtin.include_tasks | True |
| _mtv_storage_map ¦ Query for Datastores from Destination Provider | ansible.builtin.include_tasks | True |
| _mtv_storage_map ¦ Process VMware Datastores | ansible.builtin.include_tasks | True |
| _mtv_storage_map ¦ Process Ovirt Datastores | ansible.builtin.include_tasks | True |
| _mtv_storage_map ¦ Template StorageMap Map | ansible.builtin.set_fact | False |
| _mtv_storage_map ¦ Create Storage Map | redhat.openshift.k8s | False |

#### File: tasks/_mtv_storage_map_process_datastore.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| _mtv_storage_map_process_datastore ¦ Set VMware StorageMap Variables | ansible.builtin.set_fact | True |
| _mtv_storage_map_process_datastore ¦ Set Ovirt StorageMap Variables | ansible.builtin.set_fact | True |
| _mtv_storage_map_process_datastore ¦ Set VMware StorageMap StorageClass from Overrides | ansible.builtin.set_fact | True |
| _mtv_storage_map_process_datastore ¦ Set Ovirt StorageMap StorageClass from Overrides | ansible.builtin.set_fact | True |
| _mtv_storage_map_process_datastore ¦ Verify VMWare Destination Storage Class | ansible.builtin.assert | True |
| _mtv_storage_map_process_datastore ¦ Verify Ovirt Destination Storage Class | ansible.builtin.assert | True |
| _mtv_storage_map_process_datastore ¦ Template StorageMap Map | ansible.builtin.set_fact | False |
| _mtv_storage_map_process_datastore ¦ Add VMware StorageMap Map to Dict | ansible.builtin.set_fact | True |
| _mtv_storage_map_process_datastore ¦ Add Ovirt StorageMap Map to Dict | ansible.builtin.set_fact | True |

#### File: tasks/main.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| Configure MTV Providers | ansible.builtin.include_tasks | True |
| Configure MTV Maps | ansible.builtin.include_tasks | True |

#### File: tasks/mtv_maps.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| mtv_maps ¦ Retrieve Configured providers | ansible.builtin.include_tasks | False |
| mtv_maps ¦ Verify VMWare Source Provider Exists | ansible.builtin.assert | True |
| mtv_maps ¦ Verify Ovirt Source Provider Exists | ansible.builtin.assert | True |
| mtv_maps ¦ Destination OpenShift Destination Provider Exists | ansible.builtin.assert | False |
| mtv_maps ¦ Configure MTV Storage Maps | ansible.builtin.include_tasks | True |
| mtv_maps ¦ Configure MTV Network Map | ansible.builtin.include_tasks | True |

#### File: tasks/mtv_providers.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| mtv_providers ¦ Verify ForkliftController status | kubernetes.core.k8s_info | True |
| mtv_providers ¦ Debug | ansible.builtin.debug | False |
| mtv_providers ¦ Configure vmware providers | ansible.builtin.include_tasks | True |
| mtv_providers ¦ Configure ovirt providers | ansible.builtin.include_tasks | True |

#### File: tasks/mtv_query_inventory.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| mtv_query_inventory ¦ Verify valid inventory query retrieval method | ansible.builtin.assert | False |
| mtv_query_inventory ¦ Verify valid query parameters | ansible.builtin.assert | False |
| mtv_query_inventory ¦ Exec inventory retrieval method | block | True |
| mtv_query_inventory ¦ Obtain the name of a Running Forklift Inventory Pod | kubernetes.core.k8s_info | False |
| mtv_query_inventory ¦ Set name of the MTV Inventory Pod | ansible.builtin.set_fact | False |
| mtv_query_inventory ¦ Execute Query (exec) | kubernetes.core.k8s_exec | False |
| mtv_query_inventory ¦ Set Result Fact | ansible.builtin.set_fact | False |
| mtv_query_inventory ¦ Rest inventory retrieval method | block | True |
| mtv_query_inventory ¦ Locate MTV Route | kubernetes.core.k8s_info | True |
| mtv_query_inventory ¦ Verify route found | ansible.builtin.assert | False |
| mtv_query_inventory ¦ Execute Query (rest) | ansible.builtin.uri | False |
| mtv_query_inventory ¦ Set Result Fact | ansible.builtin.set_fact | False |

#### File: tasks/mtv_vddk.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| mtv_vddk ¦ Verify VDDK Secret Parameters Provided | ansible.builtin.assert | False |
| mtv_vddk ¦ Verify VDDK Image Parameters Provided | ansible.builtin.assert | False |
| mtv_vddk ¦ Create VDDK Pull Secret | kubernetes.core.k8s | False |
| mtv_vddk ¦ Manage VDDK Provided Credentials | block | True |
| mtv_vddk ¦ Retrieve Provided VDDK Credentials Secret | kubernetes.core.k8s_info | False |
| mtv_vddk ¦ Verify Provided VDDK Credentials Secret | ansible.builtin.assert | False |
| mtv_vddk ¦ Update Pull Secret Name for Provided Credential | ansible.builtin.set_fact | False |
| mtv_vddk ¦ Retrieve VDDK Service Account | kubernetes.core.k8s_info | False |
| mtv_vddk ¦ Patch Service Account with VDDK pull secret | kubernetes.core.k8s_json_patch | True |




## Playbook

```yml
---
- name: Test play
  hosts: localhost
  remote_user: root
  roles:
    - mtv_management
...

```


## Author Information
Andrew Block

#### License

GPL-3.0-only

#### Minimum Ansible Version

2.15.0

#### Platforms

- **EL**: ['all']

<!-- DOCSIBLE END -->