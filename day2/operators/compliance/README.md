
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
  oc get compliancescans
```
