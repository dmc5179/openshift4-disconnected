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
