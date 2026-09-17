# HTPasswd identity provider

https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/authentication_and_authorization/configuring-identity-providers

## Create htpasswd file
```console
htpasswd -c -B </path/to/file> <username>
```

##
```console
htpasswd -B </path/to/file> <username>
```

```console
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: my_htpasswd_provider 
    mappingMethod: claim 
    type: HTPasswd
    htpasswd:
      fileData:
        name: htpass-secret
```
