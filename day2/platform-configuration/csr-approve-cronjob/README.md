# Cron job to approve pending CSRs

```console
oc adm new-project openshift-cron-jobs
oc project openshift-cron-jobs
```

```console
oc adm policy add-cluster-role-to-user cluster-admin -z default -n openshift-cron-jobs
```

```console
oc create -n openshift-cron-jobs -f csr-approve-job.yaml
```

```console
oc create -n openshift-cron-jobs job --from=cronjob/ocp-csr-approver-cronjob csr-approve-12345
```

```console
oc create -n openshift-cron-jobs -f csr-job-cleanup.yaml
```

```console
oc get -n openshift-cron-jobs cronjob
```
