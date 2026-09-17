# Cron job to approve pending CSRs

```bash
oc adm new-project openshift-cron-jobs
oc project openshift-cron-jobs
```

```bash
oc adm policy add-cluster-role-to-user cluster-admin -z default -n openshift-cron-jobs
```

```bash
oc create -n openshift-cron-jobs -f csr-approve-job.yaml
```

```bash
oc create -n openshift-cron-jobs job --from=cronjob/ocp-csr-approver-cronjob csr-approve-12345
```

```bash
oc create -n openshift-cron-jobs -f csr-job-cleanup.yaml
```

```bash
oc get -n openshift-cron-jobs cronjob
```
