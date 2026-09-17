<!-- STATIC CONTENT START
Use this section for adding additional content to the README
This will not be overwritten by Docsible -->
# 📃 Role overview


<!-- STATIC CONTENT END -->
<!-- Everything below will be overwritten by Docsible -->
<!-- DOCSIBLE START -->
## create_mf_aap_token

```
Role belongs to infra/openshift_virtualization_migration
Namespace - infra
Collection - openshift_virtualization_migration
```

Description: create_mf_aap_token

| Field                | Value           |
|--------------------- |-----------------|
| Readme update        | 18/03/2025 |






### Defaults

**These are static variables with lower priority**

#### File: defaults/main.yml

| Var          | Type         | Value       |Choices    |Required    | Title       |
|--------------|--------------|-------------|-------------|-------------|-------------|
| [create_mf_aap_token_secure_logging](defaults/main.yml#L2)   | str   | `{{ secure_logging ¦ default(true) }}` |  n/a  |   n/a  |  n/a |





### Tasks


#### File: tasks/main.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| Initialize auth methods variable | ansible.builtin.set_fact | False |
| Ensure One OpenShift auth method provided | ansible.builtin.fail | True |
| Check whether OpenShift User/Password Enabled | ansible.builtin.set_fact | True |
| Check whether OpenShift Temporary API Key Enabled | ansible.builtin.set_fact | True |
| Check whether OpenShift API Key Provided | ansible.builtin.set_fact | True |
| Ensure multiple auth methods are not specified | ansible.builtin.debug | True |
| Use username and password to retrieve temporary API key | block | True |
| Retrieve temporary API key with username and password | redhat.openshift.openshift_auth | False |
| Set fact for temporary API key | ansible.builtin.set_fact | False |
| Create Service Account api key | block | True |
| Create API key for Migration Factory AAP | redhat.openshift.k8s | False |
| Retrieve Migration Factory AAP Service Account API key | kubernetes.core.k8s_info | False |
| Set fact with Service Account API key | ansible.builtin.set_fact | False |







## Author Information
Andrew Block

#### License

GPL-3.0-only

#### Minimum Ansible Version

2.15.0

#### Platforms

No platforms specified.
<!-- DOCSIBLE END -->