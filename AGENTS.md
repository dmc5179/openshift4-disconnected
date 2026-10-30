# AGENTS.md

Guidance for AI coding agents (Claude Code, Cursor, Codex, and so on) working in
this repo, plus the running TODO list. Humans are welcome to read it too.

## What this repo is

Scripts, manifests, Ansible roles, and notes for installing and operating
OpenShift 4 in disconnected (air-gapped) and semi-connected environments.
It's a working toolbox rather than a product, and much of the content is
reference material gathered over many OCP releases.

| Path | Contents |
|---|---|
| `day0/` | Install-time: agent-based installer, install-config examples, mirror-registry, cert rotation |
| `day2/` | Post-install: `operators/<name>/` (one dir per operator), apps, identity, machine sets, platform config |
| `oc-mirror/` | oc-mirror v1/v2 ImageSetConfigs, sample output, catalog rebuild notes |
| `scripts/` | Standalone helper scripts (`config/`, `mirroring/`, `operators/`, `installer/`, ...) |
| `playbooks/` | Older Ansible roles (originally OCP 4.3-4.5); several are marked incomplete |
| `cloudformation/` | AWS VPC and IAM templates for disconnected environments |
| `ztp/`, `podman/`, `docs/` | GitOps ZTP, container helpers, misc docs |

The top-level `README.md` describes the original Ansible workflow and is out
of date (see TODO).

## Conventions

- **Bash scripts:** `#!/bin/bash` and `set -euo pipefail`. Check required
  binaries (`oc`, `jq`) and `oc whoami` up front. Provide `--help`, and
  `--dry-run` for anything that changes a cluster.
  `day2/operators/compliance/stig-scan.sh` is the reference example.
- **Explain the why in header comments**, and cite the Red Hat doc section,
  Solution number, or bug ID a behavior depends on
  (see `scripts/config/disable_telemetry.sh`).
- **Merge, don't overwrite**, existing cluster config (ConfigMaps, CRs that
  may already carry user settings).
- **Disconnected first:** never assume `redhat-operators` exists. oc-mirror
  names mirrored catalogs `cs-redhat-operator-index[-v4-XX]`, so detect or
  accept a `--catalog` flag.
- **Versioned content goes stale:** operator profiles, channels, and API
  fields change between releases. Verify against a live cluster or current
  docs instead of trusting an old YAML in this repo.
- **Per-component README:** each `day2/operators/<name>/` dir should have a
  README that someone else could follow from a link.

## Safety rules

- **Don't commit environment-specific values:** real hostnames, IPs, pull
  secrets, kubeconfigs, cluster-generated logs (`oc-agent.log`), or generated
  ICSP/IDMS files.
- **Ask before anything that reboots nodes or can't be undone:** applying
  MachineConfigs, Compliance Operator enforce mode, removing capabilities,
  deleting namespaces.
- **Ask for the kubeconfig.** It changes per test cluster, and the default
  `~/.kube/config` often points at an unrelated cluster.
- **Commit and push only when asked.** Stage specific paths, not `git add -A`;
  the working tree usually has unrelated untracked files.

## TODO

Add items as `- [ ] <area>: <task>` with enough context to pick up cold.
Mark done items `[x]` and delete them once they're more than a release old.
Code-level TODOs are tracked inline in the code; `grep -rn TODO --exclude-dir=.git .` finds them.

### Compliance (`day2/operators/compliance/`)
- [ ] Test `stig-scan.sh --mode enforce --keep-sshd` on a disposable cluster.
      Only report mode and dry runs are tested so far (OCP 4.22.18, operator v1.10.0).
      Check MCP rollout, then rescan and record the PASS/FAIL delta in the README.
- [ ] Test `stig-scan.sh` on a disconnected cluster with a `cs-redhat-operator-index-*` catalog.
- [ ] Decide whether to keep the v2r1/v2r2 files in `profiles/` or delete them.
- [ ] Triage the 19 failed checks with no automated remediation; map them to
      `policies/` items or document them as accepted risk.

### Repo hygiene: top 10 (from full-repo scan, 2026-10-30)
Ordered by priority. The repo is **public** (44 stars, 18 forks), which raises the
priority of items 2, 4 and 5.

1. [ ] **`playbooks/`: retire it.** It holds 798 of 1,720 tracked files (46%) and
       59 roles from the OCP 4.3-4.5 era. Much of it is ansible-galaxy skeleton
       boilerplate (38 `.travis.yml` for a CI service no longer used, plus identical
       `meta/`, `tests/inventory`, `.yamllint` files). Several roles are marked
       "not complete" or "broken". It also contains a real quay.io credential (see 2).
       Tag the current state (for example `archive/playbooks-ansible`), then delete the
       directory and point the README at the tag. Port anything still useful into
       `scripts/` or `day2/` first.
2. [x] **Credentials in a public repo.** `playbooks/roles/quay/files/auth.json` and
       `playbooks/roles/quay_operator/templates/quay_auth.json` contain a base64
       `redhat+quay` robot token for quay.io. It is probably the pull token from
       old public Quay docs, but treat it as a real secret: remove it with item 1.
       It stays in git history either way, so confirm it's revoked or public.
       Run `gitleaks` or `trufflehog` over the full history, and enable GitHub secret
       scanning and push protection. (The other `*secret*.yaml` files hold only
       placeholders and are fine.)
       **Done 2026-10-30:** both auth.json files deleted. Not rotated or purged from history (owner confirmed not needed). History scan + GitHub secret scanning still worth doing under item 9.
3. [x] **Committed generated oc-mirror output.**
       `oc-mirror/v1/sequential-runs/oc-mirror-workspace/` (results-*, `mapping.txt`,
       and a 952 KB `publish/.metadata.json`, the largest file in the repo) and
       `oc-mirror/v2/sample-output/working-dir/` are raw run output full of internal
       hostnames (`ip-10-0-35-196...compute.internal`). Keep one small, scrubbed
       example of each (IDMS/ITMS + CatalogSource) and delete the rest.
       **Done 2026-10-30:** kept one scrubbed example per resource type in `oc-mirror/v2/sample-output/` and `oc-mirror/v1/sequential-runs/sample-output/` (with READMEs); deleted the raw workspaces. `pinned-ocp-release.sh` and `merge-icsp.sh` now take paths as arguments.
4. [x] **Vendored MTV collection.** `day2/operators/mtv/openshift_virtualization_migration-main/`
       is 375 files copied from `gitlab.consulting.redhat.com` (internal) under GPLv3.
       Confirm it may be published publicly. Then replace it with a README that links
       to the upstream source and documents only what's specific to this repo.
       **Done 2026-10-30:** deleted the 375-file copy (v1.21.2). `day2/operators/mtv/README.md`
       now links to the public upstream https://github.com/redhat-cop/openshift_virtualization_migration
       (1.25.0) and covers git and air-gapped installs. Not on public Galaxy as of this date.
5. [x] **No top-level LICENSE.** The README has an empty `## License` section. People
       can't legally reuse or contribute to a public repo with 18 forks, and the
       vendored GPLv3 code (item 4) complicates the choice. Pick a license (Apache-2.0
       matches most Red Hat community repos) and add `LICENSE`.
       **Done 2026-10-30:** added Apache License 2.0 (`LICENSE`) and filled in the README License section.
6. [ ] **Docs are out of date.** The top-level `README.md` still says "tested on 4.3,
       4.4, 4.5", only covers the Ansible workflow, and links into `playbooks/docs`.
       Rewrite it as an index of `day0/`, `day2/`, `oc-mirror/`, `scripts/` and
       `cloudformation/`. Also add a README to the 12 `day2/operators/*` dirs without
       one: aws, gpu, ingress, metallb, nmstate, rhacm, rhads, rhcl, rhoai, rhoso,
       sriov, validated-patterns.
7. [ ] **Environment-specific values in committed config.** `bastion.danclark.io`,
       `ip-10-0-35-196...compute.internal` and similar hostnames appear in
       `day0/agent-based-installer/install-configs/*/install-config.yaml`,
       `scripts/oauth/oauth2_generic.yaml`, `scripts/config/custom_api_certs.sh`,
       `day2/baremetal-controlplane-replacement/README.adoc` and
       `day2/operators/gitlab/README.md`. Replace them with `example.com` placeholders.
8. [ ] **`.gitignore` and the working tree.** The root `.gitignore` only ignores `*.swp`
       and `*.mine`, and 15 more are scattered in subdirectories. Consolidate into the
       root file: `oc-agent.log`, `icsp-file*`, `idms-file`, `*.log`,
       `oc-mirror-workspace/`, `working-dir/`, `auth/`, `kubeconfig`. Then sort the
       untracked files (agent-installer configs, force-cert-rotation notes,
       CNV/GitLab/Loki YAMLs, `day2/unmanaged.bu`): commit, ignore, or delete.
9. [ ] **No linting or CI for scripts and YAML.** 97 of 112 non-playbook shell scripts
       lack `set -e`, 6 aren't executable (for example `scripts/operators/path-checker.sh`,
       `ztp/setup/enable-siteconfig-operator.sh`), and 2 have no shebang
       (`day2/operators/odf/ceph_zap.sh`). Add a `pre-commit` config and a GitHub
       Action that runs `shellcheck`, `yamllint` and `gitleaks`. Fix scripts as they're
       touched instead of all at once.
10. [ ] **Superseded mirroring workflows.** `scripts/mirroring/` (last real change in
       2021), `scripts/legacy/` (2020) and `scripts/operators/` use the pre-oc-mirror
       workflow: `oc adm catalog mirror`, `opm index`, and ImageContentSourcePolicy,
       which is deprecated in favor of IDMS/ITMS. `oc-mirror/v1/` is also deprecated
       (OCP 4.20 release notes). Delete these, or move them to `archive/` with a note
       pointing to `oc-mirror/v2/`.

Smaller items:
- [ ] `day0/force-cert-rotation/ocp-force-initial-cert-rotation.sh` has a hard-coded date (`2025-11-06`).
- [ ] About 30 inline `TODO` comments, mostly in `playbooks/`. Most go away with item 1.
