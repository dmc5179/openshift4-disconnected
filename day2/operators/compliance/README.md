# OpenShift Compliance Operator: DISA STIG scanning

`stig-scan.sh` installs the Red Hat OpenShift Compliance Operator and runs the
DISA STIG profiles against a cluster. By default it **only reports**. It shows
which STIG checks pass or fail and which fixes are available, and changes
nothing on the cluster. Enforcing the STIG is a separate, explicit choice.

| Profile | What it checks |
|---|---|
| `ocp4-stig-v2r6` | OpenShift platform settings (API server, OAuth, audit, and so on) |
| `ocp4-stig-node-v2r6` | OpenShift kubelet and node settings |
| `rhcos4-stig-v2r6` | The RHCOS operating system on every master and worker |

Tested on OpenShift 4.22.18 with Compliance Operator v1.10.0.

## Prerequisites

- `oc` logged in as a cluster-admin, and `jq`
- A default StorageClass (the operator stores raw scan results in a PVC)
- The `compliance-operator` package available from a CatalogSource. On a
  connected cluster this is the default `redhat-operators` catalog. For
  disconnected clusters, see [Disconnected clusters](#disconnected-clusters).

## Quick start

```bash
git clone https://github.com/dmc5179/openshift4-disconnected.git
cd openshift4-disconnected/day2/operators/compliance

./stig-scan.sh --help          # explains every option
./stig-scan.sh --dry-run       # preview, change nothing
./stig-scan.sh                 # install the operator, scan, print a summary
```

On the test cluster (3 masters, 3 workers) the whole run took about 3 minutes
from operator install to finished scans. Larger clusters take longer. At the
end you get a summary like this:

```
SCAN                        PASS  FAIL  MANUAL  INFO  OTHER
ocp4-stig-node-v2r6-master  5     1     0       0     0
ocp4-stig-node-v2r6-worker  5     1     0       0     0
ocp4-stig-v2r6              15    23    12      0     0
rhcos4-stig-v2r6-master     17    98    1       0     0
rhcos4-stig-v2r6-worker     17    98    1       0     0

==> Remediations available: 204, applied: 0
```

`MANUAL` checks can't be evaluated automatically and need a human to review them.

## Choosing a mode

| Command | Scans | Changes the cluster | sshd on nodes |
|---|---|---|---|
| `./stig-scan.sh` | yes | no | untouched |
| `./stig-scan.sh --keep-sshd` | yes, without the sshd-disabled check | no | untouched |
| `./stig-scan.sh --mode enforce --keep-sshd` | yes | **yes, nodes reboot** | left running |
| `./stig-scan.sh --mode enforce` | yes | **yes, nodes reboot** | **disabled** |

- **report** (default) binds the profiles to the operator's built-in `default`
  ScanSetting, which has `autoApplyRemediations: false`. Proposed fixes are
  created as `ComplianceRemediation` objects with `apply: false`.
  Binding: [`stig-compliance.yaml`](stig-compliance.yaml).
- **enforce** binds the profiles to `default-auto-apply`, which has
  `autoApplyRemediations: true`. Fixes are rendered into MachineConfigs and
  KubeletConfigs, and the Machine Config Operator reboots every node to apply
  them. The script asks you to type `enforce` first; `-y` skips the prompt.
  Binding: [`stig-compliance-remediate.yaml`](stig-compliance-remediate.yaml).
- **`--keep-sshd`** creates the TailoredProfile
  [`profiles/rhcos4-stig-v2r6-with-sshd-enabled-tailored-profile.yaml`](profiles/rhcos4-stig-v2r6-with-sshd-enabled-tailored-profile.yaml).
  It is `rhcos4-stig-v2r6` minus the `rhcos4-service-sshd-disabled` rule, and
  the scan uses it instead of `rhcos4-stig-v2r6`. **Use this with enforce
  unless you are sure you never need SSH access to nodes.** Without it,
  enforce mode disables sshd on every node.

Important when enforcing:

- **Switching back to report mode does not undo anything.** Remediations that
  were already applied stay in place as `75-*` MachineConfigs. Moving to the
  `default` ScanSetting only stops *future* automatic fixes (Red Hat Solution
  7146831).
- The operator does not resolve dependencies between remediations. After the
  MachineConfigPools finish updating, rescan (see below). It can take a couple
  of enforce and rescan rounds before the results settle.
- Try enforce on a non-production cluster first. Some STIG settings (audit
  rules, crypto policy, login banners) can affect workloads or access.

You can rerun the script at any time. Switching mode or `--keep-sshd` updates
the existing `stig-compliance` binding in place and triggers a rescan.

## Disconnected clusters

1. Mirror `compliance-operator` from the Red Hat operator index. It is
   already in [`oc-mirror/v2/samples/imageset-config-421-all.yaml`](../../../oc-mirror/v2/samples/imageset-config-421-all.yaml):

   ```yaml
   operators:
     - catalog: registry.redhat.io/redhat/redhat-operator-index:v4.22
       packages:
         - name: compliance-operator
   ```

2. Apply the CatalogSource that oc-mirror generates. The script auto-detects
   any CatalogSource whose name contains `redhat-operator-index`, such as
   `cs-redhat-operator-index-v4-22`. If more than one matches, or yours is
   named differently, pass it explicitly:

   ```bash
   ./stig-scan.sh --catalog cs-redhat-operator-index-v4-22
   ```

The operator pulls its scanner and content images through the cluster's
ImageDigestMirrorSet like any other mirrored operator.

## Working with results

```bash
NS=openshift-compliance

# Scan status
oc get compliancesuite,compliancescan -n $NS

# All failed checks
oc get compliancecheckresults -n $NS -l compliance.openshift.io/check-status=FAIL

# Failed checks with no automated fix (must be handled manually)
oc get compliancecheckresults -n $NS -l 'compliance.openshift.io/check-status=FAIL,!compliance.openshift.io/automated-remediation'

# What a check is, and how to fix it
oc get compliancecheckresult <name> -n $NS -o yaml   # description + instructions
oc get complianceremediation <name> -n $NS -o yaml   # the object it would apply

# Apply one fix while staying in report mode
oc patch complianceremediation <name> -n $NS --type=merge -p '{"spec":{"apply":true}}'

# Rescan every scan in the suite
for s in $(oc get compliancesuite stig-compliance -n $NS -o jsonpath='{.spec.scans[*].name}'); do
  oc annotate compliancescan $s -n $NS compliance.openshift.io/rescan= --overwrite
done
```

After an operator content update, scan events can show
`HaveOutdatedRemediations`. To list the affected remediations:

```bash
oc get complianceremediations -n $NS -l complianceoperator.openshift.io/outdated-remediation
```

By default scans rerun daily at 01:00 (the `schedule` field on the
`default` / `default-auto-apply` ScanSettings).

## Updating to a newer STIG release

The profiles are versioned (`v2r3`, `v2r6`, ...), and newer operator releases
drop old versions. If a profile is missing, the script stops and lists the STIG
profiles the installed operator provides. To move to a new version, update the
version in all three files:

- `stig-compliance.yaml`
- `stig-compliance-remediate.yaml`
- `profiles/rhcos4-stig-<version>-with-sshd-enabled-tailored-profile.yaml`
  (the `spec.extends` field), and `TAILORED_FILE` at the top of `stig-scan.sh`

The unversioned profiles (`ocp4-stig`, `rhcos4-stig`) always track the newest
release, but the results can change without warning when the operator updates.

## Uninstall

Per the OpenShift docs, delete the operator's objects first, then the operator:

```bash
NS=openshift-compliance
oc delete ssb --all -n $NS
oc delete ss --all -n $NS
oc delete suite --all -n $NS
oc delete scan --all -n $NS
oc delete profilebundle.compliance --all -n $NS
oc delete sub --all -n $NS
oc delete csv --all -n $NS
oc delete project $NS
```

Uninstalling does **not** remove remediations that were already applied in
enforce mode. Those live in `75-*` MachineConfigs (`oc get mc | grep ^75-`).

## Other files in this directory

- `profiles/`: TailoredProfiles and bindings for manual use. The v2r1 and v2r2
  files are for older operator versions.
- `policies/`: additional hardening items (banners, MOTD, quotas, network
  policies) that the Compliance Operator flags but does not remediate.
- `default-reports/`: sample STIG compliance report exported from RHACS.

## References

- [OpenShift 4.20 Security and compliance: Compliance Operator](https://access.redhat.com/documentation/en-us/openshift_container_platform/4.20/html-single/security_and_compliance/index)
- Red Hat Solution 7146831: default vs `default-auto-apply` and safely disabling auto-remediation
