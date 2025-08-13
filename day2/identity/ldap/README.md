# Example LDAP search strings

- Sometimes ldap search WITHOUT sAMAccountName works but then we need sAMAccountName in the LDAP CR for OpenShift

# without sAMAccountName
```
ldapsearch -x -H ldap://dc.example.com -D "CN=ldap_user,OU=Users,DC=example,DC=com" -W -b "OU=My Users,DC=example,DC=com" -s sub "(uid=matt)"
```

# with sAMAccountName
ldapsearch -x -H ldap://dc.example.com -D "CN=ldap_user,OU=Users,DC=example,DC=com" -W -b "OU=My Users,DC=example,DC=com?sAMAccountName" -s sub "(uid=matt)"

oc create secret generic ldap-secret --from-literal=bindPassword=<secret> -n openshift-config

oc create configmap ca-config-map --from-file=ca.crt=/path/to/ca -n openshift-config

