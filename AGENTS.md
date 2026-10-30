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

### Linting

Config lives at the repo root: `.pre-commit-config.yaml` (shellcheck, yamllint,
gitleaks, whitespace/shebang checks), `.yamllint`, and `.gitleaks.toml`.

- Install: `pipx install pre-commit` (or `pip install --user pre-commit`).
  Hooks download their own linters on first run.
- Run on the files you touched: `pre-commit run --files <file>...`.
  Optionally `pre-commit install` to run it on every commit.
- **Don't run `pre-commit run --all-files`.** The existing repo isn't lint-clean,
  and the whitespace hooks would rewrite hundreds of files. Fix scripts as you touch them.
- CI (`.github/workflows/lint.yml`) runs shellcheck, yamllint and gitleaks on
  push/PR to `master`, but **only on files changed in that push/PR**, and gitleaks
  scans only that commit range. `playbooks/` is excluded.
- Placeholders such as `CHANGEME`, `YOUR_...`, `<access_key>` and `example.com`
  are allowlisted in `.gitleaks.toml`. Use them in examples instead of real values.

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

### Repo hygiene: top 10 (rescanned 2026-10-30, after items 2-5 below were done)
Ordered by priority. The repo is **public** (44 stars, 18 forks).

1. [ ] **`playbooks/`: retire it.** It is now 796 of 1,321 tracked files (60%):
       59 roles from the OCP 4.3-4.5 era, 38 `.travis.yml` files, ansible-galaxy
       skeleton boilerplate, and several roles marked "not complete" or "broken".
       Tag the current state (for example `archive/playbooks-ansible`), port anything
       still useful, delete the directory, and point the README at the tag.
2. [x] **Environment-specific values in a public repo** (22 files outside `playbooks/`):
       `danclark.io` (4 files), `sandbox*.opentlc.com` (4), AWS internal hostnames
       `ip-10-*.compute.internal` (6), hard-coded `/home/ec2-user` (6) and
       `/home/danclark` (5) paths, and an AWS account ID in the ARN defaults of
       `cloudformation/c2s/04_cluster_bootstrap.yaml`. Worst offenders:
       `day0/agent-based-installer/install-configs/*`, `scripts/installer/aws/*`,
       `scripts/extract.sh`, `scripts/oauth/*`, `day2/operators/gitlab/*`.
       Replace them with `example.com`, `${HOME}` and parameters.
       **Done 2026-10-30:** scrubbed 35 files (example.com, ${HOME}/overridable vars, 123456789012, password placeholders). Deliberately kept `quay.io/danclark/...` image refs (real published images) and RFC1918 lab topology in `ztp/sno1/*` and vmware configs. Removed lab passwords (vCenter, LDAP bind) are still in history; rotate them if they're still in use.
3. [ ] **`.gitignore` and the working tree.** The root `.gitignore` only ignores `*.swp`
       and `*.mine`, and 15 more are scattered in subdirectories. Consolidate into the
       root: `*.log`, `icsp-file*`, `idms-file`, `oc-mirror-workspace/`, `working-dir/`,
       `auth/`, `kubeconfig`. Then sort the 23 untracked files: commit, ignore, or delete.
       The live pull secret in untracked `day0/agent-based-installer/install-config.yaml`
       was replaced with a placeholder on 2026-10-30 (owner holds a private backup outside the repo).
4. [x] **No linting, CI or secret scanning.** There is no `.github/` directory.
       95 of 109 non-playbook shell scripts lack `set -e`, 5 aren't executable
       (`scripts/operators/path-checker.sh`, `ztp/setup/enable-siteconfig-operator.sh`,
       `day2/operators/lightspeed/rag-container.sh`,
       `oc-mirror/v1/sequential-runs/merge-icsp.sh`,
       `day2/operators/compliance/policies/rate-limit-connections/rate-limit-patch-routes.sh`),
       and `day2/operators/odf/ceph_zap.sh` has no shebang. Add `pre-commit` and a
       GitHub Action running `shellcheck`, `yamllint` and `gitleaks`, and enable GitHub
       secret scanning and push protection.
       **Done 2026-10-30:** added `.pre-commit-config.yaml`, `.yamllint`, `.gitleaks.toml`, `.github/workflows/lint.yml` (changed-files-only), chmod +x five scripts, shebang on `ceph_zap.sh`. Backlog excluding `playbooks/`: shellcheck 89 warning+ findings in 40 files, yamllint 51 errors in 19 files. GitHub secret scanning is tracked separately below.
5. [ ] **Docs are out of date.** The top-level `README.md` says "tested on 4.3, 4.4, 4.5",
       only covers the Ansible workflow, and links into `playbooks/docs`. Rewrite it as
       an index of `day0/`, `day2/`, `oc-mirror/`, `scripts/` and `cloudformation/`.
       12 `day2/operators/*` dirs have no README: aws, gpu, ingress, metallb, nmstate,
       rhacm, rhads, rhcl, rhoai, rhoso, sriov, validated-patterns.
6. [ ] **Superseded mirroring workflows.** `scripts/mirroring/` (last real change in
       2021), `scripts/legacy/` (2020) and `scripts/operators/` use the pre-oc-mirror
       workflow (`oc adm catalog mirror`, `opm index`, ICSP). `oc-mirror/v1/` is
       deprecated. Delete them, or move them to `archive/` pointing to `oc-mirror/v2/`.
7. [ ] **Deprecated `imageContentSources` / ICSP in example configs** (10 files).
       install-config uses `imageDigestSources` (4.14+), and clusters use IDMS/ITMS.
       Still on the old form: `day0/vmware/install-config.yaml`,
       `day0/agent-based-installer/vmware/install-config.yaml`,
       `day0/agent-based-installer/install-configs/{platform-baremetal,platform-none}/install-config.yaml`,
       `scripts/installer/install-config.yaml.example`,
       `oc-mirror/install-config/install-config-icsp.yaml`,
       `day2/llm-on-openshift/vllm/vllm-standalone-disconnected.md`. Convert them,
       or label them clearly as pre-4.14.
8. [x] **Scratch files and duplicates committed.**
       `oc-mirror/v2/samples/imageset-config-ocp-virt.txt` is identical to the `.yaml`
       next to it. Also notes and output dumps (`ztp/baremetal-host-postinstall/{notes,output}.txt`,
       `day2/operators/devspaces/devfile-registry/notes`, `scripts/oauth/{create,ldap_group_sync}.txt`)
       and odd suffixes (`day0/install-config-examples/install-config.yaml.existingvpc`).
       Fold useful notes into READMEs, rename variants to `*-<variant>.yaml`, delete the rest.
       **Done 2026-10-30:** deleted the duplicate and scratch files, folded `scripts/oauth/create.txt` and `devfile-registry/notes` into READMEs, renamed `install-config.yaml.existingvpc` -> `install-config-existing-vpc.yaml`.
9. [ ] **No "tested on" version labels.** 31 non-playbook files reference end-of-life
       OCP versions (4.13 or earlier), with nothing marking which content is still
       valid. Add a "Tested on OCP x.y" line to each README (as the compliance README
       does) and prune content that only applies to EOL releases.
10. [ ] **GitHub repo metadata.** The description ("Tools for disconnected installs of
       OCP 4") is fine but there are no topics, no CONTRIBUTING or issue templates, and
       no releases or tags. Add topics (`openshift`, `disconnected`, `air-gapped`,
       `oc-mirror`, `compliance-operator`), plus a short CONTRIBUTING.md that points
       at the conventions in this file.

Smaller items:
- [ ] Two YAML files don't parse: `docs/install-config-vmware-ipi.yaml:29` and
      `oc-mirror/v2/samples/imageset-config-upgrades.yaml:6`.
- [ ] `scripts/get-ocp-ca.sh` shebang typo (`#!/bin/bahs`); `snowball.sh` misuses `scp -i`/`ssh -i`.
- [ ] Enable GitHub secret scanning and push protection: repo Settings -> Code security
      (both currently disabled), or
      `gh api -X PATCH repos/dmc5179/openshift4-disconnected -F 'security_and_analysis[secret_scanning][status]=enabled' -F 'security_and_analysis[secret_scanning_push_protection][status]=enabled'`.
- [x] 2026-10-30: hard-coded default passwords in `playbooks/roles/{quay,quay_operator,create_openshift_users,ipa,podman_registry,active_directory}`
      replaced with `CHANGEME`. Lab passwords (vCenter, LDAP bind) were replaced in the tree earlier;
      owner chose not to rewrite git history.
- [ ] `playbooks/roles/quay_operator/defaults/main.yml` still has a `/home/danclark` kubeconfig path. It goes away with item 1.
- [ ] `day0/force-cert-rotation/ocp-force-initial-cert-rotation.sh` has a hard-coded date (`2025-11-06`).
- [ ] About 30 inline `TODO` comments, mostly in `playbooks/`. Most go away with item 1.

### Repo hygiene: done
- [x] 2026-10-30: **Credentials deleted.** Removed both quay.io `auth.json` files from
      `playbooks/roles/quay*`. Not rotated or purged from history (owner confirmed not needed).
- [x] 2026-10-30: **Generated oc-mirror output trimmed** to one scrubbed example per
      resource type in `oc-mirror/v2/sample-output/` and
      `oc-mirror/v1/sequential-runs/sample-output/`, with READMEs.
- [x] 2026-10-30: **Vendored MTV collection removed** (375 files, v1.21.2).
      `day2/operators/mtv/README.md` links to https://github.com/redhat-cop/openshift_virtualization_migration.
- [x] 2026-10-30: **Apache License 2.0 added** (`LICENSE` plus the README License section).
