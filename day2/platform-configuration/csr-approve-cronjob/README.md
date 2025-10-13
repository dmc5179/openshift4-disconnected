# Cron job to approve pending CSRs

```console
oc adm new-project openshift-cron-jobs
oc project openshift-cron-jobs
```

```console
oc adm policy add-cluster-role-to-user cluster-admin -z default -n openshift-cron-jobs
```

```console
oc create -f csr-approve-job.yaml
```

```console
oc create -f csr-job-cleanup.yaml
```

```console
oc get cronjob
oc get cronjob -A
oc get pod openshift-cron-jobs
```
