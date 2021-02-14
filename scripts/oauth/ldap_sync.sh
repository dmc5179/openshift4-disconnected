#!/bin/bash -xe

LDAP_URI="ldap://ldap.example.com"
INSECURE="true"

cat << EOF > ldapgroupsync.yaml
---
kind: LDAPSyncConfig
apiVersion: v1
url: ${LDAP_URI}
insecure: ${INSECURE}
rfc2307:
    groupsQuery:
        baseDN: "cn=groups,cn=accounts,dc=icsa,dc=iad,dc=redhat,dc=com"
        scope: one
        derefAliases: never
        filter: (objectClass=posixGroup)
        pageSize: 0
    groupUIDAttribute: gidNumber
    groupNameAttributes: [ cn ]
    groupMembershipAttributes: [ memberUid ]
    usersQuery:
        baseDN: "cn=users,cn=accounts,dc=icsa,dc=iad,dc=redhat,dc=com"
        scope: one
        derefAliases: never
        filter: (objectClass=posixAccount)
        pageSize: 0
    userUIDAttribute: uid
    userNameAttributes: [ cn ]
    tolerateMemberNotFoundErrors: false
    tolerateMemberOutOfScopeErrors: false
EOF


oc adm groups sync --sync-config=ldapgroupsync.yaml --confirm




exit 0



#########
git clone https://github.com/redhat-cop/openshift-management.git
oc login -u system:admin
oc adm new-project openshift-cluster-ops
oc process --local \
  -f openshift-management/jobs/cronjob-ldap-group-sync-secure.yml \
  -p NAMESPACE='openshift-cluster-ops' \
  -p LDAP_URL=ldap://ipa.shared.example.opentlc.com \
  -p LDAP_BIND_DN=uid=admin,cn=users,cn=accounts,dc=shared,dc=example,dc=opentlc,dc=com \
  -p LDAP_BIND_PASSWORD='r3dh4t1!' \
  -p LDAP_CA_CERT="$(cat ipa-ca.crt)" \
  -p LDAP_GROUP_UID_ATTRIBUTE='dn' \
  -p LDAP_GROUPS_FILTER='(objectClass=groupofnames)' \
  -p LDAP_GROUPS_SEARCH_BASE='cn=groups,cn=accounts,dc=shared,dc=example,dc=opentlc,dc=com' \
  -p LDAP_GROUPS_WHITELIST="$(cat whitelist.txt)" \
  -p LDAP_USERS_SEARCH_BASE='cn=users,cn=accounts,dc=shared,dc=example,dc=opentlc,dc=com' \
  -p SCHEDULE='*/5 * * * *' \
| oc apply -f -
oc get pod -n openshift-cluster-ops
oc logs cronjob-ldap-group-sync-<epoch>-<guid> -n openshift-cluster-ops  # from output above
