# Custom web console splash page (Not working yet)

Based on this blog https://www.redhat.com/en/blog/enhancing-the-openshift-web-console-login-experience

```console
oc adm create-login-template > login.html

oc adm create-error-template > errors.html

# Replace below with oc adm create-provider-selection-template > providers-default-template.html maybe?
CONSOLE_ROUTE=$(oc get -o jsonpath='{.spec.host}' -n openshift-console route console)
curl -sLk "https://${CONSOLE_ROUTE}/auth/login" > providers.html

sed -i $'/\/style/{e cat warningbanner.css\n}' login.html

sed -i '/<body>/ r warningbanner.html' login.html

oc create secret generic login-template --from-file=login.html -n openshift-config
oc create secret generic providers-template --from-file=providers.html -n openshift-config
oc create secret generic error-template --from-file=errors.html -n openshift-config

oc patch oauth.config.openshift.io cluster --type='json' -p='{"spec":{"templates":{"providerSelection":{"name":"providers-template"}}}}' --type=merge
```

# Remove custom splash page
```console
oc delete secret -n openshift-config login-template
oc delete secret -n openshift-config providers-template
oc delete secret -n openshift-config error-template
```
