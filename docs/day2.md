# OpenShift 4 Day 2 Operations

**Table of Contents**
  - [Purpose](#Purpose)
  - [Disable Master Scheduling](#Disable-Master-Scheduling)
  - [Disable OperatorHub](#Disable-OperatorHub)
  - [Disable Telemetry](#Disable-Telemetry)
  - [Configure Ingress Replicas](#Configure-Ingress-Replicas)
  - [Registry EmptyDir](#Registry-EmptyDir)
  - [Sample Operator Patch](#Sample-Operator-Patch)
  - [API Custom SSL Certificate](#API-Custom-SSL-Certificate)
  - [Ingres Custom SSL Certificate](#Ingres-Custom-SSL-Certificate)
  - [Warning Banner](#Warning-Banner)

### Purpose

This doc contains steps to perform simple actions in OpenShift 4

### Disable Master Scheduling
```
oc patch --type=merge --patch='{"spec":{"mastersSchedulable": false}}' schedulers.config.openshift.io cluster
```

### Disable OperatorHub
```
oc patch OperatorHub cluster --type json -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'
```

### Disable Telemetry
```
oc extract secret/pull-secret -n openshift-config --to=.

jq 'del(.auths["cloud.openshift.com"])' .dockerconfigjson > .dockerconfigjson.tmp
mv .dockerconfigjson.tmp .dockerconfigjson

oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=.dockerconfigjson

rm -f .dockerconfigjson
```

### Configure Ingress Replicas

This example sets the replicas to 2, which is the default

```
oc patch -n openshift-ingress-operator ingresscontroller/default --patch "{\"spec\":{\"replicas\": 2}}" --type=merge
```

### Registry EmptyDir

Configure the registry to use the empty dir. Useful for UPI installs that don't have a storage class yet
```
oc patch configs.imageregistry.operator.openshift.io cluster --type merge --patch '{"spec":{"storage":{"emptyDir":{}}}}'
```

### Sample Operator Patch

Patch the samples operator to reference your private registry

```
oc patch configs.samples.operator.openshift.io cluster --type merge \
  --patch "{\"spec\":{\"samplesRegistry\": \"${REMOTE_REG}\", \"managementState\": \"Managed\"}}"
```

### API Custom SSL Certificate

Create a new secret composed of the crt and the key within OpenShift.

```
oc create secret tls api-cert --cert=<path-to-crt> --key=<path-to-key> -n openshift-config
```

The next step is to update apiserver object to reference the SSL secret and add the hostname

```
oc patch apiserver cluster --type=merge 
  -p '{"spec":{"servingCerts": {"namedCertificates":[{"names": ["api.<cluster-name>.<base-domain>"], "servingCertificate": {"name": "api-cert"}}]}}}'
```

### Ingres Custom SSL Certificate

Create a new secret composed of the crt and the key within OpenShift.

```
oc create secret tls apps-cert --cert=<path-to-crt> --key=<path-to-crt> -n openshift-ingress
```

The next step is to update the default ingress controller operator to reference the SSL secret

```
oc patch ingresscontroller.operator default  --type=merge \
   -p  '{"spec":{"defaultCertificate": {"name": "apps-cert"}}}'  -n openshift-ingress-operator
```

### Warning Banner (Everywhere except the login screen)

Create the warning banner template (update settings for color and text as needed)

```
cat << EOF > warning_banner.yaml
---
apiVersion: console.openshift.io/v1
kind: ConsoleNotification
metadata:
  name: warning-banner
  namespace: openshift-config
spec:
  scope: Cluster
  backgroundColor: '#7FFF00'
  color: '#000000'
  location: BannerTop
  text: 'Highest Classification Level: Unclassified'
EOF
```

Apply the warning banner config to the cluster

```
oc create -f warning_banner.yaml
```

### Warning Banner (Login Screen, multiple identity providers)

Curl the login template from the existing cluser

```
curl -sLk https://console-openshift-console.apps.mycluster.mydomain.com/auth/login > providers.html
```

Create the warning banner CSS and HTML

```
cat << EOF > warningbanner.css
      .warningbanner {
         overflow: hidden;
         background-color: #7FFF00;
         position: fixed; /* Set the navbar to fixed position, should this be absolute????? */
         top: 0; /* Position the navbar at the top of the page */
         left: 0;
         width: 100%; /* Full width */
         text-align: center;
       }
EOF

cat << EOF > warningbanner.html
    <div class="warningbanner">
      Highest Classification Level: Unclassified
    </div>
EOF
```

Add the warning banner CSS/HTML to the providers page

```
sed -i $'/\/style/{e cat warningbanner.css\n}' providers.html
sed -i '/<body>/ r warningbanner.html' providers.html
```

Create a secret for the new providers page

```
oc create secret generic providers-template --from-file=providers.html -n openshift-config
```

Patch the cluster oauth config to use the new provider template

```
oc patch oauth.config.openshift.io cluster --type='json' -p='{"spec":{"templates":{"providerSelection":{"name":"providers-template"}}}}' --type=merge
```

