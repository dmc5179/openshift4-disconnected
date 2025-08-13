# LDAP Sync

oc adm groups sync --sync-config=config.yaml --confirm


# Running a sync cron job

oc new-project ldap-sync

oc create -f ldap-sync-service-account.yaml

oc create -f ldap-sync-cluster-role.yaml

oc create -f ldap-sync-cluster-role-binding.yaml

oc create -f ldap-sync-config-map.yaml

oc create -f ldap-sync-cron-job.yaml
