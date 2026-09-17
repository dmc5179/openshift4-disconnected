
<!-- # Merge Request Requirements for the Ansible for OpenShift Virtualization Migration collection

Thank you for your contribution to the Ansible for OpenShift Virtualization Migration collection. Please complete the following checklist to confirm that your contribution meets the desired set of standards for the project. -->

# Change Description/Details

<!-- Description of the changes included in this merge request -->

## Link to Jira Task

<!--  Associated Jira Task link -->

## Merge Request Naming

* [ ] Merge request title follows the naming convention <*Fix/Feat/Docs/Tests/CI*>: <*Jira Task*> <*PURPOSE*>. For example - *Fix: MFG-205 Add argument_specs to migration_targets role*

## Code Quality

* [ ] Code does not contain passwords, tokens, secrets or any other sensitive information
* [ ] Code Quality report shows no new findings
* [ ] [Ansible Good Practices](https://redhat-cop.github.io/automation-good-practices/#_introduction) are followed
* * [Variables are properly named](https://ansible.readthedocs.io/projects/lint/rules/var-naming/) and [leverage imlicit collection variables in role defaults](https://redhat-cop.github.io/automation-good-practices/#_create_implicit_collection_variables_and_reference_them_in_your_roles_defaults_variables)
* * ["Magic Values" not stored in code but rather in vars/main.yml](https://redhat-cop.github.io/automation-good-practices/#_vars_vs_defaults)
* * [All arguments accepted from outside the role given default value in defaults/main.yml](https://redhat-cop.github.io/automation-good-practices/#_vars_vs_defaults)
* * [Prefix task names in sub-tasks files of roles](https://redhat-cop.github.io/automation-good-practices/#_prefix_task_names_in_sub_tasks_files_of_roles)
* * [Debug statements include appropriate verbosity parameter](https://redhat-cop.github.io/automation-good-practices/#_use_the_verbosity_parameter_with_debug_statements)

## Testing and Reliability

* [ ] Role(s) work in [Check Mode](https://redhat-cop.github.io/automation-good-practices/#_check_mode)
* [ ] [Roles include argument validation in meta/argument_specs.yml](https://redhat-cop.github.io/automation-good-practices/#_argument_validation)
* [ ] Automation is [idempotant](https://redhat-cop.github.io/automation-good-practices/#_idempotency)

### Testing Resource Requirements

Check all resources are needed in the testing environment to validate modified code:

* [ ] OpenShift
* [ ] VMware
* [ ] Ansible Automation Platform
* [ ] GitLab

### Steps For Testing and Validation of Modified Code

* Step 1:

* Step 2:

* Step 3:

## Documentation

* [ ] Collection fragment added to changelogs/fragments/< Jira Task >.yml [documentation here](https://ansible.readthedocs.io/projects/antsibull-changelog/changelogs/)

*Example changelog fragment - changelogs/fragments/MFG-205.yml*

```yaml
---
minor_changes:
  - Add argument_specs to migration_targets role

bugfixes:
  - variable migration_target_speial_sauce spelling fixed to migration_target_special_sauce
...
```

* [ ] Documentation generation tool hints are included in defaults/main.yml for each variable (title, required and description) [as seen in this example](https://github.com/docsible/thermo-core/blob/main/defaults/main.yml). These hints are processed by Docsible for automatic Collection and Role README generation.

```yaml
# title: Minimum temperature required for energy generation (in °K)
# required: True
# description: The minimum core temperature required to initiate the energy synthesis process.
min_temperature_threshold: 4000

# title: Target pressure for optimal energy generation (in Pa)
# required: True
# description: Optimal pressure setting for ThermoCore to maximize energy output under safe conditions.
optimal_pressure_threshold: 4500
```

## Final Steps

* [ ] Merge not in Draft state
* [ ] Pipeline succeeds
* [ ] Notification posted to #forum-virt-migration-factory Slack channel requesting code review
