# Replacing the ingress controller with enterprise signed certificates

## Update req file

- Update the req.conf file to match your system

## Generate the CSR
```console
openssl req -new -newkey rsa:4096 -nodes -keyout ingress.key -out ingress.csr -config req.conf
```

## Submit CSR to Enterprise CA

- Submit CSR to Enterprise CA to have them sign the certificate

## Router Certs

- Replacing the ingress router certificat

```console
FULL_CHAIN_PEM="/path/to/fullchain.pem"
KEY_PEM="/path/to/server/cert/key.pem"

oc create secret tls custom-router-certs --cert=${FULL_CHAIN_PEM} --key=${KEY_PEM} -n openshift-ingress
oc patch ingresscontroller default -n openshift-ingress-operator --type=merge --patch='{"spec": { "defaultCertificate": { "name": "custom-router-certs" }}}'
```

## API Certs

- Replacing the API certificate

```console
FULL_CHAIN_PEM="/path/to/fullchain.pem"
KEY_PEM="/path/to/server/cert/key.pem"

export API=$(oc whoami --show-server | cut -f 2 -d ':' | cut -f 3 -d '/' | sed 's/-api././')

oc create secret tls api-cert --cert=${FULL_CHAIN_PEM} --key=${KEY_PEM} -n openshift-config

oc patch apiserver cluster --type merge --patch="{\"spec\": {\"servingCerts\": {\"namedCertificates\": [ { \"names\": [  \"$API\"  ], \"servingCertificate\": {\"name\": \"api-cert\" }}]}}}"
```
