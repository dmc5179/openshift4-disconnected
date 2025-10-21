# LDAP Sync for OpenShift

- Docs
https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/authentication_and_authorization/ldap-syncing

# RFC 2307 schema
The RFC 2307 schema requires you to provide an LDAP query definition for both user and group entries, as well as the attributes with which to represent them in the internal OpenShift Container Platform records.

# Active Directory schema
The Active Directory schema requires you to provide an LDAP query definition for user entries, as well as the attributes to represent them with in the internal OpenShift Container Platform group records.

# Augmented
The augmented Active Directory schema requires you to provide an LDAP query definition for both user entries and group entries, as well as the attributes with which to represent them in the internal OpenShift Container Platform group records.

## sync testing command. Will not make any changes, only show what it would do
```console
oc adm groups sync --sync-config=config.yaml
```

## Sync command that will create objects
```console
oc adm groups sync --sync-config=config.yaml --confirm
```

## Creating ldap sync as a cron job

- Create config map from your ldap sync file
```console
oc create configmap -n ldap-sync ldap-group-sync-cm --from-file=sync.yaml=config.yaml
```

- Create config map for LDAP Certificate Authority if needed
```console
oc create configmap -n ldap-sync ldap-ca --from-file=cert.pem=cert.pem
```

- Create secret for LDAP Bind Password
```console
oc create generic secret -n ldap-sync ldap-bind-password --from-file=pass=password.txt
```

- Deploy Cron job
```console
oc new-project ldap-sync

oc create -f ldap-sync-service-account.yaml

oc create -f ldap-sync-cluster-role.yaml

oc create -f ldap-sync-cluster-role-binding.yaml

oc create -f ldap-sync-cron-job.yaml
```
