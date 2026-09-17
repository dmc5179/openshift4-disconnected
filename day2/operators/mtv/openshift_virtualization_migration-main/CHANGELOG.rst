================================================
Openshift Virtualization Migration Release Notes
================================================

.. contents:: Topics

v1.21.2
=======

v1.21.1
=======

Bugfixes
--------

- Fixed JMESPath parsing error with multi-line json_query

v1.21.0
=======

Minor Changes
-------------

- Added ansible.utils dependency

v1.20.5
=======

Bugfixes
--------

- Corrected variable syntax to resolve issue with VDDK image creation secret.

v1.20.4
=======

Minor Changes
-------------

- Management of galaxy.yml dependencies

Bugfixes
--------

- Correction to aap_utilities based variables

v1.20.3
=======

Bugfixes
--------

- removed unused collections from README.md

v1.20.2
=======

Bugfixes
--------

- removed unused collections from requirements-dev.yml and galaxy.yml

v1.20.1
=======

v1.20.0
=======

Minor Changes
-------------

- MFG-420 - Added support for customizing seed content
- MFG-433 - Deprecate roles and playbooks migrated to openshift_virtualization_ops collection. Roles: vm_backup_restore, vm_hot_plug, vm_lifecycle, vm_networking, vm_patching, vm_collect Playbooks: vm_backup.yml, vm_hot_plug.yml, vm_operations.yml, vm_restore.yml, patch.yml

v1.19.1
=======

v1.19.0
=======

Minor Changes
-------------

- Bug fix in aap_seed role tasks when using AAP token
- MFG-141 - Added support for storage hot plugging + compute refactoring
- MFG-243 - Added support for updating MAC addresses of Virtual Machines
- When the _network_mgmt_manual_nad_list_ variable is not defined, only the tasks for automatic mode will be invoked. And, if the _network_mgmt_openshift_node_network_ports_ variable is not defined, only the tasks that perform the automatic configuration of NADs in NMstate will be applied to the cluster, skipping all tasks responsible for the creation of the NNCP.

Bugfixes
--------

- MFG-195 - corrected logic to verify migration completion
- MFG-220 - add antsibull-changelog release into build and release script

v1.15.2
=======

Minor Changes
-------------

- Add infra.virt_migration_factory.aap_deploy role
- Add infra.virt_migration_factory.aap_deploy role
- Add variable to disable dependency checking for controller_configuration which was causing a failure
- Add variable to disable dependency checking for controller_configuration which was causing a failure
- Added README to .gitlab folder for how to add CI/CD variables to pull content
- Added README to .gitlab folder for how to add CI/CD variables to pull content
- Added a default hosts value for preseed playbooks to remediate linting errors
- Added a default hosts value for preseed playbooks to remediate linting errors
- Added an rc script to pipeline to identify path to dnf and pip package manager
- Added an rc script to pipeline to identify path to dnf and pip package manager
- Added docsible hints to mtv_management defaults/main.yml
- Added docsible hints to mtv_management defaults/main.yml
- Added docsible hints to mtv_migrate defaults/main.yml
- Added docsible hints to mtv_migrate defaults/main.yml
- Added docsible role template to remove the version number that created a lot of churn
- Added docsible role template to remove the version number that created a lot of churn
- Added fqcn[canonical] exception in .ansible-lint-ignore to avoid bug suggesting kubernetes.core.k8s_info instead of redhat.openshift.k8s
- Added fqcn[canonical] exception in .ansible-lint-ignore to avoid bug suggesting kubernetes.core.k8s_info instead of redhat.openshift.k8s
- Added meta/argument_specs.yml to mtv_migrate role
- Added meta/argument_specs.yml to mtv_migrate role
- Added path support for VM and Folder migrations
- Added path support for VM and Folder migrations
- Added setup_env.sh script for installing local tools including pre-commit
- Added setup_env.sh script for installing local tools including pre-commit
- Added support for RHV as a Migration Target
- Added support for RHV as a Migration Target
- Added the ability to specify the namespace Providers, StorageMaps and NetworkMaps are created in
- Added the ability to specify the namespace Providers, StorageMaps and NetworkMaps are created in
- Additional update for migration annotation
- Additional update for migration annotation
- Adds support for specifying credentials for the VDDK init image
- Adds support for specifying credentials for the VDDK init image
- Changed all gitlab ci file extensions (except ./.gitlab-ci.yml) to use .yaml extension to provide type hinting for IDEs and linters
- Changed all gitlab ci file extensions (except ./.gitlab-ci.yml) to use .yaml extension to provide type hinting for IDEs and linters
- Changed offline settings from true to false in .ansible-lint config to eliminate extra downloads of cached content
- Changed offline settings from true to false in .ansible-lint config to eliminate extra downloads of cached content
- Commented vars reference aap channel and version on inventory because now they have default values defined.
- Commented vars reference aap channel and version on inventory because now they have default values defined.
- Disabled allow_failure setting on ansible-lint min profile
- Disabled allow_failure setting on ansible-lint min profile
- Fix linting error issues reported by Automation Hub collection submission
- Fix linting error issues reported by Automation Hub collection submission
- Fixed Jinja2 spacing in roles mtv_migrate mtv_management to pass ansible linting
- Fixed Jinja2 spacing in roles mtv_migrate mtv_management to pass ansible linting
- Fixed literal true/false in mtv_migrate role when conditional
- Fixed literal true/false in mtv_migrate role when conditional
- Fixed var-naming linting errors by conforming to ROLENAME_VARNAME
- Fixed var-naming linting errors by conforming to ROLENAME_VARNAME
- Install all collections (including those requiring a subscription) prior to linting. Version requirements were set at greater than or equal to what is latest today.
- Install all collections (including those requiring a subscription) prior to linting. Version requirements were set at greater than or equal to what is latest today.
- Organized requirements.yml with comments to clarify content sources
- Organized requirements.yml with comments to clarify content sources
- Remove migration_targets role
- Remove migration_targets role
- Remove playbooks pre_config.yml and tor_switch.yml
- Remove playbooks pre_config.yml and tor_switch.yml
- Remove roles tor_switch_gathering, tor_switch_migrate, pre_config
- Remove roles tor_switch_gathering, tor_switch_migrate, pre_config
- Removed references to non-existant roles that were removed as part of clean up
- Removed references to non-existant roles that were removed as part of clean up
- Rename nmstate role to network_mgmt and support for manually defining network configurations
- Rename nmstate role to network_mgmt and support for manually defining network configurations
- Switched docsible to run against individual roles instead of the entire collection
- Switched docsible to run against individual roles instead of the entire collection
- Update migration_factory_aap playbook to use new role
- Update migration_factory_aap playbook to use new role
- Updated pipeline to leverage both published and validated content sources
- Updated pipeline to leverage both published and validated content sources
- Updated the role READMEs to include a space for static content
- Updated the role READMEs to include a space for static content
- Updates to support AAP 2.5 for aap_machine_credentials role
- Updates to support AAP 2.5 for aap_machine_credentials role
- Validate vms_per_plan property
- Validate vms_per_plan property
- Verify AAP components are running after installation.
- Verify AAP components are running after installation.

Breaking Changes / Porting Guide
--------------------------------

- Rename collection to infra.openshift_virtualization_migration
- Rename collection to infra.openshift_virtualization_migration
- Rename colleection to redhat.openshift_virtualization_migration
- Rename colleection to redhat.openshift_virtualization_migration

Bugfixes
--------

- Added default value of '2.5' for aap_version var on aap_deploy role.
- Added default value of '2.5' for aap_version var on aap_deploy role.
- Added default value of 'stable-2.5' for aap_channel var on aap_deploy role.
- Added default value of 'stable-2.5' for aap_channel var on aap_deploy role.
- Additional check for empty nmstate and mapping properties of migration_targets
- Additional check for empty nmstate and mapping properties of migration_targets
- Correct invalid variable in vm_lifecycle role
- Correct invalid variable in vm_lifecycle role
- Corrected VDDK variable names
- Corrected VDDK variable names
- Corrected mtv_management_migration_namespace variable name
- Corrected mtv_management_migration_namespace variable name
- Define default value of true for validate_certs attribute when openshift_verify_ssl is not defined on create_mf_aap_token role
- Define default value of true for validate_certs attribute when openshift_verify_ssl is not defined on create_mf_aap_token role
- Fixed code coverage job that was failing due to not being able to find pip
- Fixed code coverage job that was failing due to not being able to find pip
- Fixed pipeline to properly cache roles that were included in the base image
- Fixed pipeline to properly cache roles that were included in the base image
- Fixed requirements file to add redhat.openshift_virtualization collection
- Fixed requirements file to add redhat.openshift_virtualization collection
- Isolated the linting issues due to not having the collection dependencies installed
- Isolated the linting issues due to not having the collection dependencies installed
- Remove dependencies in mtv_migrate role
- Remove dependencies in mtv_migrate role
- Updated variables and documentation for vm_backup_restore role
- Updated variables and documentation for vm_backup_restore role
