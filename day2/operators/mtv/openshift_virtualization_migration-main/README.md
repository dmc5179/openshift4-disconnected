# Ansible for OpenShift Virtualization Migration

Ansible collection for OpenShift Virtualization Migration

## Description

This collection enables the migration journey of Virtual Machine (VM) workloads from existing hypervisors to Red Hat OpenShift Virtualization using Ansible Automation Platform. Additionally it provides content for the management and maintenance of VM workloads within Red Hat OpenShift Virtualization.

## Requirements

The following Ansible Collections are required:

```yaml
---
collections:
  - name: redhat.openshift_virtualization
  - name: redhat.openshift
  - name: vmware.vmware_rest
  - name: ansible.posix
  - name: infra.aap_utilities
  - name: kubernetes.core
  - name: community.crypto
  - name: community.general
  - name: community.vmware

  # AAP <=2.4
  - name: infra.controller_configuration
  - name: ansible.controller
    version: "<=4.5.12"

  # AAP 2.5+
  - name: ansible.platform
  - name: ansible.controller
  - name: infra.aap_configuration
...
```

## Installation

You can install the `infra.openshift_virtualization_migration` collection with the Ansible Galaxy CLI:

```shell
ansible-galaxy collection install infra.openshift_virtualization_migration
```

Note that if you install any collections from Ansible Galaxy, they will not be upgraded automatically when you upgrade the Ansible package.

To upgrade the collection to the latest available version, run the following command:

```
ansible-galaxy collection install infra.openshift_virtualization_migration --upgrade
```

You can also include it in a `requirements.yml` file and install it with `ansible-galaxy collection install -r requirements.yml`, using the format:

```yaml
---
collections:
  - name: infra.openshift_virtualization_migration
    # If you need a specific version of the collection, you can specify like this:
    # version: ...
```

See [using Ansible collections](https://docs.ansible.com/ansible/devel/user_guide/collections_using.html) for more details.

## Use Cases

This collection is ideal for accomplishing the following using Ansible automation:

* Analyzing existing Virtual Machine hypervisor environments.
* Installing and configuring Ansible Automation Platform.
* Preparing OpenShift environments to support Virtual Machines and migrating Virtual Machines from existing hypervisors using the Migration Toolkit for Virtualization (MTV).
* Migrating Virtual Machines using the Migration Toolkit for Virtualization (MTV).

## Testing

[tox](https://tox.wiki) is used to perform tests and verification of this collection.

The following commands can be used to execute the various types of tests implemented:

```shell
tox -av # lists all tests

tox # run them all

tox -e <test name> # run specific one

tox -f sanity --ansible -c tox-ansible.ini     # run tox-ansible that does our ansible-test sanity suite
```

## Support

The [Ansible Forum](https://forum.ansible.com/tag/openshift_migrate) can be used for additional questions and issues related to this collection.

## Release Notes

Information related to the releases for this collection can be found in the Release Notes found within this collection.

## License Information

GNU General Public License v3.0 or later.

See the [LICENSE](https://www.gnu.org/licenses/gpl-3.0.en.html) to see the full text.
