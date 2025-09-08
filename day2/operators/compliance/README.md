
# List findings that must be manually configured
```console
oc get -n openshift-compliance compliancecheckresults -l 'compliance.openshift.io/check-status=FAIL,!compliance.openshift.io/automated-remediation'
```

# Initiate rescan
```console
oc annotate -n openshift-compliance compliancescans/ocp4-stig-v2r1 compliance.openshift.io/rescan=
```

# Check status
```console
  oc get -n openshift-compliance compliancescans
```

# Sometimes see a warning from the above command that look like below:

```
Normal   HaveOutdatedRemediations  11h                scanctrl  The scan produced outdated remediations, please check for complianceremediation objects labeled with complianceoperator.openshift.io/outdated-remediation
```

# TODO: Add command to find the outdated remediations mentioned above
```console
oc get -n openshift-compliance compliancecheckresults -l '
```
