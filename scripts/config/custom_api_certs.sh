#!/bin/bash

#TODO: This script doesn't quite work right yet.

#oc create secret tls api-cert --cert=${HOME}/certs/cert.pem --key=${HOME}/certs/key.pem -n openshift-config
#
#oc patch apiserver cluster --type=merge \
#  -p '{"spec":{"servingCerts": {"namedCertificates":[{"names": ["api.cluster.example.com"], "servingCertificate": {"name": "api-cert"}}]}}}'
#

#oc create secret tls api-certs --cert=${HOME}/certs/fullchain.pem --key=${HOME}/certs/key.pem -n openshift-ingress
#oc patch apiserver cluster --type=merge \
#  -p '{"spec":{"servingCerts": {"namedCertificates":[{"names": ["api.cluster.example.com"], "servingCertificate": {"name": "api-certs"}}]}}}'

