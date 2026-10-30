#!/bin/bash

BIND_PW='pw'
INSECURE="true"

cat << EOF > /tmp/ldap-oauth.yaml
---
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: ldap
    mappingMethod: claim
    type: LDAP
    ldap:
      attributes:
        id:
        - dn
        email:
        - mail
        name:
        - cn
        preferredUsername:
        - uid
      bindDN: "uid=admin,cn=users,cn=compat,dc=example,dc=com"
      bindPassword:
        name: ldap-secret
      insecure: ${INSECURE}
      url: "ldap://ldap.example.com/cn=users,cn=accounts,dc=example,dc=com?uid?one"
EOF

oc create secret generic ldap-secret "--from-literal=bindPassword=${BIND_PW}" -n openshift-config

# Create the CA if using ldaps secure
#oc create configmap ca-config-map --from-file=ca.crt=/path/to/ca -n openshift-config

oc create -f /tmp/ldap-oauth.yaml
rm -f /tmp/ldap-oauth.yaml
