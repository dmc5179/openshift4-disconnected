<!-- STATIC CONTENT START
Use this section for adding additional content to the README
This will not be overwritten by Docsible -->
# 📃 Role overview


<!-- STATIC CONTENT END -->
<!-- Everything below will be overwritten by Docsible -->
<!-- DOCSIBLE START -->
## bootstrap

```
Role belongs to infra/openshift_virtualization_migration
Namespace - infra
Collection - openshift_virtualization_migration
```

Description: Initialization of the Ansible for OpenShift Virtualization Migration environment.

| Field                | Value           |
|--------------------- |-----------------|
| Readme update        | 18/03/2025 |






### Defaults

**These are static variables with lower priority**

#### File: defaults/main.yml

| Var          | Type         | Value       |Choices    |Required    | Title       |
|--------------|--------------|-------------|-------------|-------------|-------------|
| [bootstrap_user](defaults/main.yml#L6)   | str   | `ansible` |  n/a  |   true  |  This is the bootstrap user with sudo that should already exist on the bootsrap host |
| [bootstrap_public_keys](defaults/main.yml#L10)   | list   | `[]` |  n/a  |   false  |  Add a list of SSH public keys to be added to authorized_keys on the bootstrap VM |
| [bootstrap_aap_setup_working_dir](defaults/main.yml#L14)   | str   | `/home/ansible/bootstrap_dir` |  n/a  |   true  |  Working direcotry on the bootstrap host |
| [bootstrap_rh_username](defaults/main.yml#L18)   | str   | `{{ rh_username }}` |  n/a  |   true  |  Red Hat account login (this is used to attach your subs to controller) |
| [bootstrap_rh_password](defaults/main.yml#L22)   | str   | `{{ rh_password }}` |  n/a  |   true  |  Red Hat account password |
| [bootstrap_rh_pool_id](defaults/main.yml#L26)   | str   | `` |  n/a  |   true  |  Red Hat pool ID |
| [bootstrap_rh_filter_product_name](defaults/main.yml#L30)   | str   | `Red Hat Ansible Automation Platform` |  n/a  |   false  |  Red Hat subscription product name |
| [bootstrap_rh_filter_support_level](defaults/main.yml#L34)   | str   | `Self-Support` |  n/a  |   false  |  Red Hat subscription support level |
| [bootstrap_controller_password](defaults/main.yml#L38)   | str   | `{{ controller_password }}` |  n/a  |   true  |  The admin password for the controller |
| [bootstrap_aap_setup_inst_verbosity](defaults/main.yml#L42)   | int   | `1` |  n/a  |   false  |  Level from 0 - 5 for verbosity |
| [bootstrap_aap_license_manifest](defaults/main.yml#L46)   | str   | `` |  n/a  |   false  |  Location of the AAP license manifest file |
| [bootstrap_controller_hostname](defaults/main.yml#L55)   | str   | `{{ controller_hostname ¦ default(ansible_host) }}` |  n/a  |   false  |  Bootstrap controller hostname |
| [bootstrap_controller_username](defaults/main.yml#L59)   | str   | `admin` |  n/a  |   false  |  Bootstrap controller username |
| [bootstrap_aap_version](defaults/main.yml#L63)   | str   | `{{ aap_version ¦ default(2.5) }}` |  n/a  |   false  |  Bootstrap AAP Version |
| [bootstrap_controller_validate_certs](defaults/main.yml#L67)   | str   | `{{ controller_validate_certs ¦ default(false) }}` |  n/a  |   false  |  Validate Controller SSL certificates |
| [bootstrap_license_file_submission_retries](defaults/main.yml#L73)   | int   | `25` |  n/a  |   True  |  License File Submission Retries |
| [bootstrap_license_file_submission_delay](defaults/main.yml#L79)   | int   | `10` |  n/a  |   True  |  License File Submission Delay |





### Tasks


#### File: tasks/aap_subscription.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| aap_subscription ¦ Get subscriptions with a filter | block | True |
| aap_subscription ¦ Query Subscription | ansible.controller.subscriptions | False |
| aap_subscription ¦ Set pool based on bootstrap_subscription | ansible.builtin.set_fact | False |
| aap_subscription ¦ Attach to a pool | ansible.controller.license | False |
| aap_subscription ¦ Verify License Manifest Exists | block | True |
| aap_subscription ¦ Check if license file exists | ansible.builtin.stat | False |
| aap_subscription ¦ Verify license file exists | ansible.builtin.assert | False |
| aap_subscription ¦ Read the License file | ansible.builtin.slurp | False |
| aap_subscription ¦ Apply license to AAP | ansible.builtin.uri | False |

#### File: tasks/create_mf_aap_token.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| create_mf_aap_token ¦ Create API key for Migration Factory AAP | redhat.openshift.k8s | False |
| create_mf_aap_token ¦ Retrieve Migration Factory AAP Service Account API key | kubernetes.core.k8s_info | False |
| create_mf_aap_token ¦ Set fact with Service Account API key | ansible.builtin.set_fact | False |
| create_mf_aap_token ¦ Print Migration Factory AAP Service Account API key | ansible.builtin.debug | False |

#### File: tasks/main.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| Subscribe AAP | ansible.builtin.include_tasks | False |

#### File: tasks/prep.yml

| Name | Module | Has Conditions |
| ---- | ------ | --------- |
| prep ¦ Register to Red Hat with provided credentials | community.general.redhat_subscription | False |
| prep ¦ Setup new user | ansible.builtin.user | False |
| prep ¦ Allow passwordless sudo for '{{ bootstrap_user }}' | ansible.builtin.copy | False |
| prep ¦ Create SSH folder | ansible.builtin.file | False |
| prep ¦ Generate an OpenSSH keypair with the default values | community.crypto.openssh_keypair | False |
| prep ¦ Set authorized key taken from file | ansible.posix.authorized_key | False |
| prep ¦ Set SSH config for this host to enable automated install | ansible.builtin.copy | False |
| prep ¦ Create working directory | ansible.builtin.file | False |




## Playbook

```yml
---
- name: Test
  hosts: localhost
  remote_user: root
  roles:
    - bootstrap
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