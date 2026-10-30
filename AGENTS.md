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

### Repo hygiene
- [ ] Sort the untracked files in the working tree: commit, gitignore, or delete
      (agent-installer configs, `oc-agent.log`, `icsp-file*`, `idms-file`,
      force-cert-rotation notes, CNV/GitLab/Loki YAMLs, `day2/unmanaged.bu`).
- [ ] Add `.gitignore` entries for generated files (`oc-agent.log`, `icsp-file*`, `idms-file`).
- [ ] Rewrite the top-level `README.md`: it still says "tested on 4.3, 4.4, 4.5"
      and only covers the Ansible workflow.
- [ ] `day0/force-cert-rotation/ocp-force-initial-cert-rotation.sh` has a hard-coded date (`2025-11-06`).
