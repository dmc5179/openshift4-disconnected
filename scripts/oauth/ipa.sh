#!/bin/bash

BIND_PW='pw'
INSECURE="true"

cat << EOF > /tmp/icsaldap.yaml
---
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: icsaldap
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
      bindDN: "uid=admin,cn=users,cn=compat,dc=icsa,dc=iad,dc=redhat,dc=com"
      bindPassword:
        name: ldap-secret
      insecure: ${INSECURE}
      url: "ldap://enterprise.icsa.iad.redhat.com/cn=users,cn=accounts,dc=icsa,dc=iad,dc=redhat,dc=com?uid?one"
EOF

oc create secret generic ldap-secret "--from-literal=bindPassword=${BIND_PW}" -n openshift-config

# Create the CA if using ldaps secure
#oc create configmap ca-config-map --from-file=ca.crt=/path/to/ca -n openshift-config

oc create -f /tmp/icsaldap.yaml
rm -f /tmp/icsaldap.yaml
