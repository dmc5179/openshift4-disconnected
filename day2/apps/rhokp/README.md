# Red Hat Offline Knowledge Portal

## Obtain Access Key

- Follow the steps here to get your access key

https://docs.redhat.com/en/documentation/red_hat_offline_knowledge_portal/1/html/user_guide/proc_launching-rhokp

## Deploy the RHOKP to OpenShift

- Update the deployment yaml with your access key

- Create a new namespace
```console
oc new-project rhokp
```

- Deploy RHOKP
```console
oc create -f rhokp-deployment.yaml
```

