# Migration Toolkit for Virtualization (MTV)

For automating VM migrations to OpenShift Virtualization with MTV and Ansible
Automation Platform, use the Red Hat Community of Practice collection
`infra.openshift_virtualization_migration`. It lives upstream; this repo no
longer keeps a copy.

| | |
|---|---|
| Collection source | https://github.com/redhat-cop/openshift_virtualization_migration |
| Example playbooks | https://github.com/redhat-cop/openshift-virtualization-migration-playbooks |
| Documentation | https://github.com/redhat-cop/openshift-virtualization-migration-documentation |
| Execution environments | https://github.com/redhat-cop/openshift_virtualization_migration_ees |

Latest release when this README was written: **1.25.0** (2026-05-06). The
copy previously kept here was 1.21.2.

## Install

Install straight from the GitHub release tag:

```bash
ansible-galaxy collection install \
  git+https://github.com/redhat-cop/openshift_virtualization_migration.git,1.25.0
```

Or in `requirements.yml`:

```yaml
collections:
  - name: https://github.com/redhat-cop/openshift_virtualization_migration.git
    type: git
    version: 1.25.0
```

The upstream README also documents
`ansible-galaxy collection install infra.openshift_virtualization_migration`,
but as of 2026-10-30 the collection is not listed on public Ansible Galaxy.
The git install above works either way.

### Disconnected environments

On the connected side, build a tarball and carry it across:

```bash
git clone --branch 1.25.0 https://github.com/redhat-cop/openshift_virtualization_migration.git
ansible-galaxy collection build openshift_virtualization_migration/
# copy infra-openshift_virtualization_migration-1.25.0.tar.gz across the air gap, then:
ansible-galaxy collection install infra-openshift_virtualization_migration-1.25.0.tar.gz
```

Collection dependencies (listed in its `galaxy.yml`) need to be downloaded
the same way, for example with `ansible-galaxy collection download -r requirements.yml`.
Several of them (`redhat.openshift_virtualization`, `redhat.openshift`,
`ansible.controller`) are certified collections, so they come from Red Hat
Automation Hub (console.redhat.com) rather than Galaxy. Configure an Automation
Hub token in `ansible.cfg` before downloading.

## License

The collection is GPL-3.0 licensed upstream. This repo is Apache-2.0.
