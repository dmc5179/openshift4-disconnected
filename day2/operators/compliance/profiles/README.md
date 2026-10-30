# Apply tailored profile

Use the version that matches the STIG profiles shipped by the installed
Compliance Operator (`oc get profiles.compliance.openshift.io -n openshift-compliance | grep stig`).
Compliance Operator v1.10.0 ships v2r3 and v2r6; v2r1 and v2r2 are only for older operator versions.

```bash
oc create -f rhcos4-stig-v2r6-with-sshd-enabled-tailored-profile.yaml
```

```bash
oc apply -f ocp4-stig-v2r6-scan-setting-binding-with-sshd-enabled-auto-apply.yaml
```
