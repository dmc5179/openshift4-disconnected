<!-- STATIC CONTENT START
Use this section for adding additional content to the README
This will not be overwritten by Docsible -->
# 📃 Role overview


<!-- STATIC CONTENT END -->
<!-- Everything below will be overwritten by Docsible -->
<!-- DOCSIBLE START -->
## aap_deploy

```
Role belongs to infra/openshift_virtualization_migration
Namespace - infra
Collection - openshift_virtualization_migration
```

Description: Deploys an instance of Ansible Automation Platform.

| Field                | Value           |
|--------------------- |-----------------|
| Readme update        | 18/03/2025 |






### Defaults

**These are static variables with lower priority**

#### File: defaults/main.yml

| Var          | Type         | Value       |Choices    |Required    | Title       |
|--------------|--------------|-------------|-------------|-------------|-------------|
| [aap_deploy_aap_install](defaults/main.yml#L7)   | bool   | `True` |  n/a  |   True  |  Boolean to allow AAP instalation and subscription attachment |
| [aap_deploy_controller_username](defaults/main.yml#L18)   | str   | `{{ controller_username ¦ default('admin', true) }}` |  n/a  |   True  |  Username for AAP Controller authentication |
| [aap_deploy_openshift_host](defaults/main.yml#L23)   | str   | `{{ openshift_host }}` |  n/a  |   True  |  OpenShift cluster hostname |
| [aap_deploy_openshift_api_key](defaults/main.yml#L28)   | str   | `{{ openshift_api_key }}` |  n/a  |   False  |  OpenShift API authentication key |
| [aap_deploy_openshift_verify_ssl](defaults/main.yml#L33)   | str   | `{{ openshift_verify_ssl }}` |  n/a  |   False  |  Verify SSL certificates for OpenShift connection |
| [aap_deploy_validate_components](defaults/main.yml#L38)   | list   | `["{{ aap_instance_name + '-controller-task' if aap_version is not defined or aap_version is version('2.5', '>=') else aap_instance_name + '-web' }}", "{{ aap_instance_name + '-controller-task' if aap_version is not defined or aap_version is version('2.5', '>=') else aap_instance_name + '-task' }}", "{{ aap_instance_name + '-gateway' if aap_version is not defined or aap_version is version('2.5', '>=') else '' }}"]` |  n/a  |   True  |  Ansible Automation Platform component validation |
| [aap_deploy_cac_collection](defaults/main.yml#L49)   | str   | `{{ 'infra.controller_configuration' if aap_version is defined and aap_version is version('2.5', '<') else 'infra.aap_configuration' }}` |  n/a  |   True  |  Ansible Automation Platform configuration collection |
| [aap_deploy_aap_channel](defaults/main.yml#L53)   | str   | `{{ aap_channel ¦ default('stable-2.5') }}` |  n/a  |   n/a  |  n/a |
<summary><b>🖇️ Full descriptions for vars in defaults/main.yml</b></summary>
<br>
<b>aap_deploy_aap_install:</b> Setting this variable to true will install AAP and attach a valid subscription based on your account.
<br>
<b>aap_deploy_controller_username:</b> Username used to authenticate against the AAP Controller.
<br>
<b>aap_deploy_openshift_host:</b> The hostname or API endpoint of the OpenShift cluster to validate bearer token.
<br>
<b>aap_deploy_openshift_api_key:</b> API key used to authenticate against the OpenShift cluster.
<br>
<b>aap_deploy_openshift_verify_ssl:</b> Whether to verify SSL certificates when connecting to OpenShift.
<br>
<b>aap_deploy_validate_components:</b> The names of the components to verify is running after installation.
<br>
<b>aap_deploy_cac_collection:</b> Determines which collection to use for configuring AAP based on the version.
<br>
<br>





### Tasks


#### File: tasks/install.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| install ¦ Validate OpenShift bearer token | ansible.builtin.uri | False |
| install ¦ Set Platform variables (2.5+) | ansible.builtin.set_fact | True |
| install ¦ Set Platform variables (<2.5) | ansible.builtin.set_fact | True |
| install ¦ Call aap_ocp_install role | ansible.builtin.import_role | False |
| install ¦ Verify AAP Components are running | kubernetes.core.k8s_info | True |
| install ¦ Bootstrap block | block | True |
| install ¦ Set controller username fact for Bootstrap mode | ansible.builtin.set_fact | False |
| install ¦ Retrieve Migration Factory AAP admin credential for Bootstrap mode | kubernetes.core.k8s_info | False |
| install ¦ Set controller facts for bootstrap mode | ansible.builtin.set_fact | False |
| install ¦ Set controller stats for bootstrap mode | ansible.builtin.set_stats | False |
| install ¦ Call credential config as code role on Bootstrap AAP | ansible.builtin.include_role | False |
| install ¦ Non-bootstrap block | block | True |
| install ¦ Set controller username fact for non-bootstrap mode | ansible.builtin.set_fact | False |
| install ¦ Retrieve Migration Factory AAP admin credential for non-bootstrap mode | kubernetes.core.k8s_info | False |
| install ¦ Set controller facts if not bootstrap mode | ansible.builtin.set_fact | False |
| install ¦ Set controller stats if not bootstrap mode | ansible.builtin.set_stats | False |
| install ¦ Display retrieved password for non-bootstrap mode | ansible.builtin.debug | False |

#### File: tasks/main.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| Install AAP | ansible.builtin.include_tasks | True |
| Attach AAP Subscriptions | ansible.builtin.include_tasks | True |

#### File: tasks/subscribe.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| subscribe ¦ Call bootstrap role to subscribe | ansible.builtin.import_role | True |
| subscribe ¦ Call bootstrap role to subscribe | ansible.builtin.import_role | True |




## Playbook

```yml
---
- name: Test
  hosts: localhost
  remote_user: root
  roles:
    - aap_deploy
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