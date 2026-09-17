<!-- STATIC CONTENT START
Use this section for adding additional content to the README
This will not be overwritten by Docsible -->
# 📃 Role overview
This role defines the initial configuration and setup of the Ansible Automation Platform with the organizations, inventories, projects, job templates, credentials, execution environments for the Ansible Collection for OpenShift Virtualization Migration.

<!-- STATIC CONTENT END -->
<!-- Everything below will be overwritten by Docsible -->
<!-- DOCSIBLE START -->
## aap_seed

```
Role belongs to infra/openshift_virtualization_migration
Namespace - infra
Collection - openshift_virtualization_migration
```

Description: Populates an Ansible Automation Platform instance.

| Field                | Value           |
|--------------------- |-----------------|
| Readme update        | 18/03/2025 |






### Defaults

**These are static variables with lower priority**

#### File: defaults/main.yml

| Var          | Type         | Value       |Choices    |Required    | Title       |
|--------------|--------------|-------------|-------------|-------------|-------------|
| [aap_seed_secure_logging](defaults/main.yml#L5)   | str   | `{{ secure_logging ¦ default(true) }}` |  n/a  |   True  |  AAP Secure Logging |
| [aap_seed_migration_hub](defaults/main.yml#L10)   | list   | `[]` |  n/a  |   True  |  AAP Migration Hub |
| [aap_seed_aap_namespace](defaults/main.yml#L15)   | str   | `{{ aap_namespace }}` |  n/a  |   True  |  AAP Namespace in OpenShift |
| [aap_seed_aap_channel](defaults/main.yml#L20)   | str   | `{{ aap_channel }}` |  n/a  |   True  |  AAP Subscription Channel |
| [aap_seed_aap_instance_name](defaults/main.yml#L25)   | str   | `{{ aap_instance_name }}` |  n/a  |   True  |  AAP Instance Name |
| [aap_seed_aap_org_name](defaults/main.yml#L30)   | str   | `{{ aap_org_name }}` |  n/a  |   True  |  AAP Organization Name |
| [aap_seed_controller_username](defaults/main.yml#L35)   | str   | `{{ controller_username ¦ default(aap_username) ¦ default(lookup('ansible.builtin.env', 'CONTROLLER_USERNAME')) }}` |  n/a  |   True  |  AAP Controller Username |
| [aap_seed_controller_password](defaults/main.yml#L42)   | str   | `{{ controller_password ¦ default(aap_password) ¦ default(lookup('ansible.builtin.env', 'CONTROLLER_PASSWORD')) }}` |  n/a  |   True  |  AAP Controller Password |
| [aap_seed_controller_token](defaults/main.yml#L48)   | str   | `{{ controller_oauthtoken ¦ default(aap_token) ¦ default(lookup('ansible.builtin.env', 'CONTROLLER_TOKEN')) }}` |  n/a  |   False  |  AAP token |
| [aap_seed_controller_hostname](defaults/main.yml#L51)   | str   | `{{ controller_hostname ¦ default(aap_hostname) ¦ default(lookup('ansible.builtin.env', 'CONTROLLER_HOSTNAME')) }}` |  n/a  |   n/a  |  n/a |
| [aap_seed_controller_validate_certs](defaults/main.yml#L58)   | str   | `{{ controller_validate_certs ¦ default(aap_validate_certs) ¦ default(lookup('ansible.builtin.env', 'CONTROLLER_VERIFY_SSL')) }}` |  n/a  |   True  |  Validate AAP Controller Certificate |
| [aap_seed_cac_collection](defaults/main.yml#L65)   | str   | `{{ 'infra.controller_configuration' if aap_version is defined and aap_version is version('2.5', '<') else 'infra.aap_configuration' }}` |  n/a  |   True  |  AAP CaC Collection Name |
| [aap_seed_controller_organizations_var](defaults/main.yml#L72)   | str   | `{{ 'controller_organizations' if aap_version is defined and aap_version is version('2.5', '<') else 'aap_organizations' }}` |  n/a  |   True  |  AAP Organizations Variable |
| [aap_seed_controller_configuration_async_retries](defaults/main.yml#L81)   | int   | `60` |  n/a  |   True  |  Configuration Async Retries |
| [aap_seed_controller_dependency_check](defaults/main.yml#L86)   | bool   | `False` |  n/a  |   True  |  Dependency Check |
| [aap_seed_aap_inventory](defaults/main.yml#L93)   | str   | `openshift_virtualization_migration` |  n/a  |   True  |  AAP Inventory |
| [aap_seed_aap_version](defaults/main.yml#L98)   | str   | `{{ aap_version ¦ default(2.5) }}` |  n/a  |   True  |  AAP Version |
| [aap_seed_aap_execution_environment](defaults/main.yml#L103)   | str   | `{{ aap_execution_environment }}` |  n/a  |   True  |  AAP Execution Environment |
| [aap_seed_aap_execution_environment_image](defaults/main.yml#L108)   | str   | `{{ aap_execution_environment_image }}` |  n/a  |   True  |  AAP Execution Environment Image |
| [aap_seed_aap_project](defaults/main.yml#L113)   | str   | `{{ aap_project }}` |  n/a  |   True  |  AAP Project |
| [aap_seed_aap_project_branch](defaults/main.yml#L118)   | str   | `{{ aap_project_branch }}` |  n/a  |   True  |  AAP Project Branch |
| [aap_seed_aap_project_repo](defaults/main.yml#L123)   | str   | `{{ aap_project_repo }}` |  n/a  |   True  |  AAP Project Repository |
| [aap_seed_automation_hub_certified_credential_name](defaults/main.yml#L128)   | str   | `{{ automation_hub_certified_credential_name ¦ default('Red Hat Automation Hub Certified') }}` |  n/a  |   True  |  Automation Hub Certified Name |
| [aap_seed_automation_hub_validated_credential_name](defaults/main.yml#L134)   | str   | `{{ automation_hub_validated_credential_name ¦ default('Red Hat Automation Hub Validated') }}` |  n/a  |   True  |  Automation Hub Validated Name |
| [aap_seed_automation_hub_certified_url](defaults/main.yml#L140)   | str   | `{{ automation_hub_certified_url }}` |  n/a  |   True  |  Automation Hub Certified URL |
| [aap_seed_automation_hub_certified_auth_url](defaults/main.yml#L145)   | str   | `{{ automation_hub_certified_auth_url }}` |  n/a  |   True  |  Automation Hub Certified URL |
| [aap_seed_automation_hub_certified_token](defaults/main.yml#L150)   | str   | `{{ automation_hub_certified_token }}` |  n/a  |   True  |  Automation Hub Token |
| [aap_seed_automation_hub_validated_url](defaults/main.yml#L155)   | str   | `{{ automation_hub_validated_url }}` |  n/a  |   True  |  Automation Hub Validated URL |
| [aap_seed_automation_hub_validated_auth_url](defaults/main.yml#L160)   | str   | `{{ automation_hub_validated_auth_url }}` |  n/a  |   True  |  Automation Hub Validated Authorization URL |
| [aap_seed_automation_hub_validated_token](defaults/main.yml#L165)   | str   | `{{ automation_hub_validated_token }}` |  n/a  |   True  |  Automation Hub Validated Token |
| [aap_seed_git_credential_name](defaults/main.yml#L170)   | str   | `{{ (git_credential_name is defined) ¦ ansible.builtin.ternary(git_credential_name, 'Git') }}` |  n/a  |   True  |  Git Credential Name |
| [aap_seed_git_username](defaults/main.yml#L176)   | str   | `{{ (git_username is defined) ¦ ansible.builtin.ternary(git_username, '') }}` |  n/a  |   True  |  Git Username |
| [aap_seed_git_password](defaults/main.yml#L181)   | str   | `{{ (git_password is defined) ¦ ansible.builtin.ternary(git_password, '') }}` |  n/a  |   True  |  Git Password |
| [aap_seed_git_ssh_private_key](defaults/main.yml#L186)   | str   | `{{ (git_ssh_private_key is defined) ¦ ansible.builtin.ternary(git_ssh_private_key, '') }}` |  n/a  |   True  |  Git SSH Private Key |
| [aap_seed_git_ssh_key_passphrase](defaults/main.yml#L193)   | str   | `{{ (git_ssh_key_passphrase is defined) ¦ ansible.builtin.ternary(git_ssh_key_passphrase, '') }}` |  n/a  |   True  |  Git SSH Private Key Passphrase |
| [aap_seed_vmware_host](defaults/main.yml#L202)   | str   | `{{ vmware_host }}` |  n/a  |   True  |  VMware Host |
| [aap_seed_vmware_user](defaults/main.yml#L207)   | str   | `{{ vmware_user }}` |  n/a  |   True  |  VMware Username |
| [aap_seed_vmware_password](defaults/main.yml#L212)   | str   | `{{ vmware_password }}` |  n/a  |   True  |  VMware Password |
| [aap_seed_vmware_validate_certs](defaults/main.yml#L217)   | str   | `{{ vmware_validate_certs }}` |  n/a  |   True  |  Validate VMware Certificate |
| [aap_seed_vmware_cacert](defaults/main.yml#L222)   | str   | `{{ vmware_cacert }}` |  n/a  |   True  |  VMware CA Certificate |
| [aap_seed_vmware_context_path](defaults/main.yml#L227)   | str   | `{{ vmware_context_path }}` |  n/a  |   True  |  VMware Context Path |
| [aap_seed_container_credential_name](defaults/main.yml#L232)   | str   | `{{ container_credential_name ¦ default('Container Registry') }}` |  n/a  |   True  |  AAP Container Credential Name |
| [aap_seed_container_host](defaults/main.yml#L237)   | str   | `{{ container_host }}` |  n/a  |   True  |  AAP Container Host |
| [aap_seed_container_password](defaults/main.yml#L242)   | str   | `{{ container_password }}` |  n/a  |   True  |  AAP Container Password |
| [aap_seed_container_username](defaults/main.yml#L247)   | str   | `{{ container_username }}` |  n/a  |   True  |  AAP Container Username |
| [aap_seed_container_verify_ssl](defaults/main.yml#L252)   | str   | `{{ container_verify_ssl ¦ default(false) }}` |  n/a  |   True  |  Container Verify SSL |
| [aap_seed_aap_job_template_extra_vars](defaults/main.yml#L257)   | str   | `{{ aap_job_template_extra_vars ¦ default('{}') }}` |  n/a  |   True  |  AAP Job Template Variables |
| [aap_seed_migration_targets](defaults/main.yml#L262)   | str   | `{{ migration_targets ¦ default([]) }}` |  n/a  |   True  |  Migration Targets |
| [aap_seed_operator_management_hub](defaults/main.yml#L268)   | list   | `['acm', 'oadp', 'far', 'nho']` |  n/a  |   True  |  Default Management Hub Operators |
| [aap_seed_operator_management_spoke](defaults/main.yml#L278)   | list   | `['mtv', 'cnv', 'oadp', 'far', 'nmstate', 'nho']` |  n/a  |   True  |  Default Spoke Operators |
| [aap_seed_ansible_galaxy_credential_enabled](defaults/main.yml#L289)   | bool   | `True` |  n/a  |   True  |  Enable Ansible Galaxy Credential |
| [aap_seed_ansible_galaxy_credential_name](defaults/main.yml#L294)   | str   | `Ansible Galaxy` |  n/a  |   True  |  Name of the Ansible Galaxy Credential |
| [aap_seed_automation_hub_credentials_create](defaults/main.yml#L299)   | bool   | `True` |  n/a  |   True  |  Create Automation Hub Credentials |
| [aap_seed_automation_hub_credentials](defaults/main.yml#L304)   | list   | `[{'name': '{{ aap_seed_automation_hub_certified_credential_name }}', 'description': 'Red Hat Automation Hub Certified Credential', 'organization': '{{ aap_seed_aap_org_name }}', 'credential_type': 'Ansible Galaxy/Automation Hub API Token', 'inputs': {'url': '{{ aap_seed_automation_hub_certified_url }}', 'auth_url': '{{ aap_seed_automation_hub_certified_auth_url }}', 'token': '{{ aap_seed_automation_hub_certified_token }}'}}, {'name': '{{ aap_seed_automation_hub_validated_credential_name }}', 'description': 'Red Hat Automation Hub Validated Credential', 'organization': '{{ aap_seed_aap_org_name }}', 'credential_type': 'Ansible Galaxy/Automation Hub API Token', 'inputs': {'url': '{{ aap_seed_automation_hub_validated_url }}', 'auth_url': '{{ aap_seed_automation_hub_validated_auth_url }}', 'token': '{{ aap_seed_automation_hub_validated_token }}'}}]` |  n/a  |   True  |  Automation Hub Credentials |
| [aap_seed_controller_credentials](defaults/main.yml#L325)   | list   | `[]` |  n/a  |   True  |  Credentials to Seed |
| [aap_seed_controller_credential_types](defaults/main.yml#L330)   | list   | `[{'name': 'openshift_virtualization_migration_cac', 'description': 'OpenShift Virtualization Migration Config-as-Code Data structure', 'organization': '{{ aap_seed_aap_org_name }}', 'kind': 'cloud', 'inputs': {'fields': [{'id': 'aap_version', 'type': 'string', 'label': 'AAP Version'}, {'id': 'aap_instance_name', 'type': 'string', 'label': 'AAP Instance Name'}, {'id': 'aap_execution_environment', 'type': 'string', 'label': 'AAP Execution Environment'}, {'id': 'aap_org_name', 'type': 'string', 'label': 'AAP Org Name'}, {'id': 'aap_namespace', 'type': 'string', 'label': 'AAP Namespace'}, {'id': 'aap_project', 'type': 'string', 'label': 'AAP Project Name'}, {'id': 'aap_inventory', 'type': 'string', 'label': 'AAP Inventory'}, {'id': 'aap_job_template_extra_vars', 'type': 'string', 'label': 'Job Template Extra Variables', 'secret': True}, {'id': 'migration_targets', 'type': 'string', 'label': 'Migration Targets', 'multiline': True, 'secret': True}], 'required': ['aap_version', 'aap_instance_name', 'aap_execution_environment', 'aap_org_name', 'aap_project', 'aap_inventory']}, 'injectors': {'extra_vars': {'aap_version': '{% raw %}{  { aap_version }}{% endraw %}', 'aap_instance_name': '{% raw %}{  { aap_instance_name }}{% endraw %}', 'aap_execution_environment': '{% raw %}{  { aap_execution_environment }}{% endraw %}', 'aap_org_name': '{% raw %}{  { aap_org_name }}{% endraw %}', 'aap_project': '{% raw %}{  { aap_project }}{% endraw %}', 'aap_inventory': '{% raw %}{  { aap_inventory }}{% endraw %}', 'aap_namespace': '{% raw %}{  { aap_namespace }}{% endraw %}', 'aap_job_template_extra_vars': '{% raw %}{  { aap_job_template_extra_vars }}{% endraw %}', 'provided_migration_targets': '{% raw %}{  { migration_targets }}{% endraw %}'}}}, {'name': 'VMware Migration Target', 'description': 'Migration Target for VMware', 'organization': '{{ aap_seed_aap_org_name }}', 'kind': 'cloud', 'inputs': {'fields': [{'id': 'name', 'type': 'string', 'label': 'Target Name'}, {'id': 'host', 'type': 'string', 'label': 'VCenter Host'}, {'id': 'username', 'type': 'string', 'label': 'Username'}, {'id': 'password', 'type': 'string', 'label': 'Password', 'secret': True}, {'id': 'insecure_ssl', 'type': 'boolean', 'label': 'Skip Validate VMware Certificate Verification'}, {'id': 'cacert', 'type': 'string', 'label': 'VMware CA Certificate', 'multiline': True}, {'id': 'context_path', 'type': 'string', 'label': 'VMware Context Path'}, {'id': 'credentials_secret_ref', 'type': 'string', 'label': 'Credentials Secret Reference'}, {'id': 'vddk_init_image', 'type': 'string', 'label': 'VDDK Init Image'}, {'id': 'vddk_init_image_username', 'type': 'string', 'label': 'VDDK Init Image Username'}, {'id': 'vddk_init_image_password', 'type': 'string', 'label': 'VDDK Init Image Password', 'secret': True}, {'id': 'vddk_init_image_credentials_secret', 'type': 'string', 'label': 'VDDK Init Image Credentials Secret'}, {'id': 'provider_name', 'type': 'string', 'label': 'Provider source'}], 'required': ['name', 'host', 'provider_name']}, 'injectors': {'extra_vars': {'vmware_target_name': '{% raw %}{  { name }}{% endraw %}', 'vmware_insecure_ssl': '{% raw %}{  { insecure_ssl }}{% endraw %}', 'vmware_cacert': '{% raw %}{  { cacert }}{% endraw %}', 'vmware_context_path': '{% raw %}{  { context_path }}{% endraw %}', 'vmware_credentials_secret_ref': '{% raw %}{  { credentials_secret_ref }}{% endraw %}', 'vmware_vddk_init_image': '{% raw %}{  { vddk_init_image }}{% endraw %}', 'vmware_vddk_init_image_username': '{% raw %}{  { vddk_init_image_username }}{% endraw %}', 'vmware_vddk_init_image_password': '{% raw %}{  { vddk_init_image_password }}{% endraw %}', 'vmware_vddk_init_image_credentials_secret': '{% raw %}{  { vddk_init_image_credentials_secret }}{% endraw %}', 'provider': '{% raw %}{  { provider_name }}{% endraw %}'}, 'env': {'VMWARE_HOST': '{% raw %}{  { host }}{% endraw %}', 'VMWARE_USER': '{% raw %}{  { username }}{% endraw %}', 'VMWARE_PASSWORD': '{% raw %}{  { password }}{% endraw %}'}}}, {'name': 'Ovirt Migration Target', 'description': 'Migration Target for Ovirt', 'organization': '{{ aap_seed_aap_org_name }}', 'kind': 'cloud', 'inputs': {'fields': [{'id': 'name', 'type': 'string', 'label': 'Target Name'}, {'id': 'host', 'type': 'string', 'label': 'Ovirt Host'}, {'id': 'username', 'type': 'string', 'label': 'Username'}, {'id': 'password', 'type': 'string', 'label': 'Password', 'secret': True}, {'id': 'insecure_ssl', 'type': 'boolean', 'label': 'Skip Validate Ovirt Certificate Verification'}, {'id': 'cacert', 'type': 'string', 'label': 'Ovirt CA Certificate', 'multiline': True}, {'id': 'context_path', 'type': 'string', 'label': 'Ovirt Context Path'}, {'id': 'credentials_secret_ref', 'type': 'string', 'label': 'Credentials Secret Reference'}, {'id': 'provider_name', 'type': 'string', 'label': 'Provider source'}], 'required': ['name', 'host', 'provider_name']}, 'injectors': {'extra_vars': {'ovirt_target_name': '{% raw %}{  { name }}{% endraw %}', 'ovirt_insecure_ssl': '{% raw %}{  { insecure_ssl }}{% endraw %}', 'ovirt_cacert': '{% raw %}{  { cacert }}{% endraw %}', 'ovirt_context_path': '{% raw %}{  { context_path }}{% endraw %}', 'ovirt_credentials_secret_ref': '{% raw %}{  { credentials_secret_ref }}{% endraw %}', 'provider': '{% raw %}{  { provider_name }}{% endraw %}'}, 'env': {'OVIRT_HOST': '{% raw %}{  { host }}{% endraw %}', 'OVIRT_USER': '{% raw %}{  { username }}{% endraw %}', 'OVIRT_PASSWORD': '{% raw %}{  { password }}{% endraw %}'}}}]` |  n/a  |   True  |  Credential Types |
| [aap_seed_controller_organizations](defaults/main.yml#L507)   | list   | `[{'name': '{{ aap_seed_aap_org_name }}', 'galaxy_credentials': "{{ ([aap_seed_ansible_galaxy_credential_name] if aap_seed_ansible_galaxy_credential_enabled else []) + (aap_seed_automation_hub_credentials ¦ map(attribute='name') if aap_seed_automation_hub_credentials_create else []) }}"}]` |  n/a  |   True  |  Organization |
| [aap_seed_controller_projects](defaults/main.yml#L516)   | list   | `[{'name': '{{ aap_seed_aap_project }}', 'organization': '{{ aap_seed_aap_org_name }}', 'scm_branch': '{{ aap_seed_aap_project_branch }}', 'scm_clean': 'no', 'scm_delete_on_update': 'no', 'scm_type': 'git', 'scm_update_on_launch': 'yes', 'scm_url': '{{ aap_seed_aap_project_repo }}', 'credential': '{{ aap_seed_git_credential_name }}', 'local_path': 'infra/openshift_virtualization_migration'}]` |  n/a  |   The project in AAP where the collection will reside  |  Project |
| [aap_seed_controller_execution_environments](defaults/main.yml#L531)   | list   | `[{'name': '{{ aap_seed_aap_execution_environment }}', 'image': '{{ aap_seed_aap_execution_environment_image }}', 'pull': 'always', 'credential': "{{ aap_seed_container_credential_name if aap_seed_container_credential_name ¦ default('', true) ¦ length > 0 else '' }}"}]` |  n/a  |   True  |  Execution Environment |
| [aap_seed_controller_inventories](defaults/main.yml#L542)   | list   | `[{'name': '{{ aap_seed_aap_inventory }}', 'organization': '{{ aap_seed_aap_org_name }}'}]` |  n/a  |   True  |  Inventory |
| [aap_seed_controller_hosts](defaults/main.yml#L549)   | list   | `[{'name': 'localhost', 'inventory': '{{ aap_seed_aap_inventory }}', 'variables': {'ansible_connection': 'local', 'ansible_python_interpreter': '{  { ansible_playbook_python }}'}}]` |  n/a  |   True  |  Host |
| [aap_seed_controller_templates](defaults/main.yml#L559)   | list   | `[{'name': 'OpenShift Virtualization Migration - Migrate', 'organization': '{{ aap_seed_aap_org_name }}', 'project': '{{ aap_seed_aap_project }}', 'job_type': 'run', 'ask_variables_on_launch': True, 'extra_vars': '{{ aap_seed_aap_job_template_extra_vars }}', 'playbook': 'playbooks/mtv_migrate.yml', 'inventory': '{{ aap_seed_aap_inventory }}', 'execution_environment': '{{ aap_seed_aap_execution_environment }}', 'ask_credential_on_launch': True}]` |  n/a  |   True  |  AAP Controller Templates |
| [aap_seed_controller_workflow_launch_jobs](defaults/main.yml#L577)   | NoneType   | `None` |  n/a  |   True  |  Workflow Launch Jobs |
| [aap_seed_organization_create](defaults/main.yml#L584)   | bool   | `True` |  n/a  |   True  |  Create Organization |
| [aap_seed_projects_create](defaults/main.yml#L589)   | bool   | `True` |  n/a  |   True  |  Create Projects |
| [aap_seed_execution_environments_create](defaults/main.yml#L594)   | bool   | `True` |  n/a  |   True  |  Create Execution Environments |
| [aap_seed_credential_types_create](defaults/main.yml#L599)   | bool   | `True` |  n/a  |   True  |  Create Credential Types |
| [aap_seed_inventories_create](defaults/main.yml#L604)   | bool   | `True` |  n/a  |   True  |  Create Inventories |
| [aap_seed_hosts_create](defaults/main.yml#L609)   | bool   | `True` |  n/a  |   True  |  Create Hosts |
| [aap_seed_job_templates_create](defaults/main.yml#L614)   | bool   | `True` |  n/a  |   True  |  Create Job Templates |
| [aap_seed_workflow_job_templates_create](defaults/main.yml#L619)   | bool   | `True` |  n/a  |   True  |  Create Workflow Job Templates |
| [aap_seed_aap_credentials_create](defaults/main.yml#L624)   | bool   | `True` |  n/a  |   True  |  Create AAP Credentials |
| [aap_seed_project_credentials_create](defaults/main.yml#L629)   | bool   | `True` |  n/a  |   True  |  Create Project Credentials |
| [aap_seed_migration_targets_credentials_create](defaults/main.yml#L634)   | bool   | `True` |  n/a  |   True  |  Create Migration Target Credentials |
| [aap_seed_container_registry_credentials_create](defaults/main.yml#L639)   | bool   | `True` |  n/a  |   True  |  Create Container Registry Credentials |
<summary><b>🖇️ Full descriptions for vars in defaults/main.yml</b></summary>
<br>
<b>aap_seed_secure_logging:</b> Enable Secure Logging
<br>
<b>aap_seed_migration_hub:</b> AAP Migration Hub
<br>
<b>aap_seed_aap_namespace:</b> AAP Namespace in OpenShift
<br>
<b>aap_seed_aap_channel:</b> AAP Subscription Channel
<br>
<b>aap_seed_aap_instance_name:</b> AAP Instance Name
<br>
<b>aap_seed_aap_org_name:</b> Name of the organization in AAP
<br>
<b>aap_seed_controller_username:</b> AAP Controller Username
<br>
<b>aap_seed_controller_password:</b> AAP Controller Password
<br>
<b>aap_seed_controller_token:</b> AAP token to use for the AAP controller, not required if aap_username and aap_password are set
<br>
<b>aap_seed_controller_validate_certs:</b> Validate AAP Controller Certificate
<br>
<b>aap_seed_cac_collection:</b> If AAP is 2.5< use infra.controller_configuration otherwise use infra.aap_configuration
<br>
<b>aap_seed_controller_organizations_var:</b> If AAP is 2.5< use controller_organizations, otherwise use aap_organizations
<br>
<b>aap_seed_controller_configuration_async_retries:</b> Maximum number of of asynchronous retries
<br>
<b>aap_seed_controller_dependency_check:</b> Verify availability and configuration of the required dependencies for the EE
<br>
<b>aap_seed_aap_inventory:</b> AAP Inventory used for the collection
<br>
<b>aap_seed_aap_version:</b> AAP Version
<br>
<b>aap_seed_aap_execution_environment:</b> AAP Execution Environment
<br>
<b>aap_seed_aap_execution_environment_image:</b> AAP Execution Environment Image
<br>
<b>aap_seed_aap_project:</b> AAP Project
<br>
<b>aap_seed_aap_project_branch:</b> AAP Project Branch in the git repo
<br>
<b>aap_seed_aap_project_repo:</b> AAP Project Repository that contains the Ansible Collection for OpenShift Virtualization Migration
<br>
<b>aap_seed_automation_hub_certified_credential_name:</b> Automation Hub Certified Name
<br>
<b>aap_seed_automation_hub_validated_credential_name:</b> Automation Hub Validated Name
<br>
<b>aap_seed_automation_hub_certified_url:</b> Automation Hub Certified URL
<br>
<b>aap_seed_automation_hub_certified_auth_url:</b> Automation Hub Authorization URL
<br>
<b>aap_seed_automation_hub_certified_token:</b> Automation Hub Token
<br>
<b>aap_seed_automation_hub_validated_url:</b> Automation Hub Validated URL
<br>
<b>aap_seed_automation_hub_validated_auth_url:</b> Automation Hub Validated Authorization URL
<br>
<b>aap_seed_automation_hub_validated_token:</b> Automation Hub Validated Token
<br>
<b>aap_seed_git_credential_name:</b> Git Credential Name
<br>
<b>aap_seed_git_username:</b> Git Username
<br>
<b>aap_seed_git_password:</b> Git Password
<br>
<b>aap_seed_git_ssh_private_key:</b> Git SSH Private Key
<br>
<b>aap_seed_git_ssh_key_passphrase:</b> Git SSH Private Key Passphrase
<br>
<b>aap_seed_vmware_host:</b> VMware Host
<br>
<b>aap_seed_vmware_user:</b> VMware Username
<br>
<b>aap_seed_vmware_password:</b> VMware Password
<br>
<b>aap_seed_vmware_validate_certs:</b> Validate VMware Certificate
<br>
<b>aap_seed_vmware_cacert:</b> VMware CA Certificate
<br>
<b>aap_seed_vmware_context_path:</b> VMware Context Path
<br>
<b>aap_seed_container_credential_name:</b> AAP Container Credential Name
<br>
<b>aap_seed_container_host:</b> AAP Container Host that runs the execution environment
<br>
<b>aap_seed_container_password:</b> AAP Container Password
<br>
<b>aap_seed_container_username:</b> AAP Container Username
<br>
<b>aap_seed_container_verify_ssl:</b> Determines whether SSL certificates are verified when pulling EE images
<br>
<b>aap_seed_aap_job_template_extra_vars:</b> AAP Job Template Extra Variables
<br>
<b>aap_seed_migration_targets:</b> Migration Targets
<br>
<b>aap_seed_operator_management_hub:</b> Default Management Hub Operators
<br>
<b>aap_seed_operator_management_spoke:</b> Default Spoke Operators
<br>
<b>aap_seed_ansible_galaxy_credential_enabled:</b> Enable Ansible Galaxy Credential in AAP Organization Credentials
<br>
<b>aap_seed_ansible_galaxy_credential_name:</b> Name of the Ansible Galaxy Credential
<br>
<b>aap_seed_automation_hub_credentials_create:</b> Create Automation Hub Credentials in AAP Organization Credentials
<br>
<b>aap_seed_automation_hub_credentials:</b> Defines the Automation Hub credentials to be used by AAP
<br>
<b>aap_seed_controller_credentials:</b> Credentials to Seed
<br>
<b>aap_seed_controller_credential_types:</b> Defines the Config as Code Credential Types
<br>
<b>aap_seed_controller_organizations:</b> AAP Organization for OpenShift Virtualization Migration
<br>
<b>aap_seed_controller_execution_environments:</b> The execution environment where the ansible playbooks for OpenShift Virtualization Migration will run
<br>
<b>aap_seed_controller_inventories:</b> Target inventory for OpenShift Virtualization Migration
<br>
<b>aap_seed_controller_hosts:</b> The hosts where the migration will run
<br>
<b>aap_seed_controller_templates:</b> AAP controller templates to seed
<br>
<b>aap_seed_controller_workflow_launch_jobs:</b> Workflow Launch Jobs
<br>
<b>aap_seed_organization_create:</b> Create Organization
<br>
<b>aap_seed_projects_create:</b> Create Projects
<br>
<b>aap_seed_execution_environments_create:</b> Create Execution Environments
<br>
<b>aap_seed_credential_types_create:</b> Create Credential Types
<br>
<b>aap_seed_inventories_create:</b> Create Inventories
<br>
<b>aap_seed_hosts_create:</b> Create Hosts
<br>
<b>aap_seed_job_templates_create:</b> Create Job Templates
<br>
<b>aap_seed_workflow_job_templates_create:</b> Create Workflow Job Templates
<br>
<b>aap_seed_aap_credentials_create:</b> Create AAP Credentials
<br>
<b>aap_seed_project_credentials_create:</b> Create Project Credentials
<br>
<b>aap_seed_migration_targets_credentials_create:</b> Create Migration Target Credentials
<br>
<b>aap_seed_container_registry_credentials_create:</b> Create Container Registry Credentials
<br>
<br>





### Tasks


#### File: tasks/_build_credentials.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| _build_credentials ¦ Create migration factory api token for {{ _mf_host }} | ansible.builtin.include_role | True |
| _build_credentials ¦ Set openshift_api_key var on {{ _mf_host }} | ansible.builtin.set_fact | True |
| _build_credentials ¦ Build migration targets | ansible.builtin.set_fact | True |
| _build_credentials ¦ Build Migration Factory CaC Credential for {{ _mf_host }} | ansible.builtin.set_fact | True |
| _build_credentials ¦ Build kubeconfig for {{ _mf_host }} | ansible.builtin.set_fact | False |

#### File: tasks/_build_job_templates.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| _build_job_templates ¦ Build list of operators to install | block | False |
| _build_job_templates ¦ Clear operator list | ansible.builtin.set_fact | False |
| _build_job_templates ¦ Add hub operators | ansible.builtin.set_fact | True |
| _build_job_templates ¦ Add spoke operators | ansible.builtin.set_fact | True |
| _build_job_templates ¦ Build Operator Job Template | ansible.builtin.set_fact | False |
| _build_job_templates ¦ Build MTV Job Templates | ansible.builtin.include_tasks | True |

#### File: tasks/_mtv_job_templates.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| _mtv_job_templates ¦ Configure VMWare MTV Job Template | ansible.builtin.set_fact | True |
| _mtv_job_templates ¦ Configure Ovirt MTV Job Template | ansible.builtin.set_fact | True |

#### File: tasks/_mtv_workflow_job_templates.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| _mtv_workflow_job_templates ¦ Build MTV Target Workflows for {{ _mf_host }} | ansible.builtin.set_fact | False |
| _mtv_workflow_job_templates ¦ Get list of MTV Target workflow names | ansible.builtin.set_fact | False |
| _mtv_workflow_job_templates ¦ Build MTV workflow | ansible.builtin.set_fact | False |

#### File: tasks/credentials.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| credentials ¦ Set credentials variable | ansible.builtin.set_fact | False |
| credentials ¦ Build AAP Credential | ansible.builtin.set_fact | True |
| credentials ¦ Build Automation Hub Credentials | ansible.builtin.set_fact | True |
| credentials ¦ Build Project Credential | ansible.builtin.set_fact | True |
| credentials ¦ Build Container Registry Credential | ansible.builtin.set_fact | True |
| credentials ¦ Build Operator Management Credentials | block | True |
| credentials ¦ Build Migration Target Credentials | ansible.builtin.set_fact | True |
| credentials ¦ Build required credentials | ansible.builtin.include_tasks | False |

#### File: tasks/job_templates.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| job_templates ¦ Set templates variable | ansible.builtin.set_fact | False |
| job_templates ¦ Build Operator Install Job Templates | ansible.builtin.include_tasks | False |

#### File: tasks/main.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| Set controller_configuration vars | ansible.builtin.set_fact | False |
| Build Credentials | ansible.builtin.include_tasks | False |
| Build Job Templates | ansible.builtin.include_tasks | True |
| Build Workflows | ansible.builtin.include_tasks | True |
| Ensure AAP API credentials are set | ansible.builtin.assert | False |
| Check if both username/password and token are defined | ansible.builtin.debug | True |
| Wait for API to become available using username and password | ansible.builtin.uri | True |
| Wait for API to become available using token | ansible.builtin.uri | True |
| Call dispatch role | ansible.builtin.include_role | False |

#### File: tasks/workflows.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| workflows ¦ Set workflow variables | ansible.builtin.set_fact | False |
| workflows ¦ Build Operator Workflows | ansible.builtin.set_fact | False |
| workflows ¦ Build MTV Target Workflows | ansible.builtin.include_tasks | False |
| workflows ¦ Build MTV Worklfow | ansible.builtin.set_fact | False |
| workflows ¦ Build Migration Factory Worklfow | ansible.builtin.set_fact | False |







## Author Information
Matthew Taylor

#### License

GPL-3.0-only

#### Minimum Ansible Version

2.15.0

#### Platforms

No platforms specified.
<!-- DOCSIBLE END -->