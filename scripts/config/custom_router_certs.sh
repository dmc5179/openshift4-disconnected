#!/bin/bash

# The full chain pem contains the server certificate and the CA all in one.
# You can create a full chain pem by concatenating the server cert and the CA into one pem file
FULL_CHAIN_PEM="/path/to/fullchain.pem"

KEY_PEM="/path/to/server/cert/key.pem"

oc create secret tls custom-router-certs --cert=${FULL_CHAIN_PEM} --key=${KEY_PEM} -n openshift-ingress

oc patch ingresscontroller default -n openshift-ingress-operator --type=merge --patch='{"spec": { "defaultCertificate": { "name": "custom-router-certs" }}}'
