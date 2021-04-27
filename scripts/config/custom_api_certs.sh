#!/bin/bash

#TODO: This script doesn't quite work right yet.

#oc create secret tls api-cert --cert=/home/danclark/openshift_clusters/aws_certs/cert.pem --key=/home/danclark/openshift_clusters/aws_certs/key.pem -n openshift-config
#
#oc patch apiserver cluster --type=merge \
#  -p '{"spec":{"servingCerts": {"namedCertificates":[{"names": ["api.dan.danclark.io"], "servingCertificate": {"name": "api-cert"}}]}}}'
#

#oc create secret tls api-certs --cert=/home/danclark/openshift_clusters/aws_certs/fullchain.pem --key=/home/danclark/openshift_clusters/aws_certs/key.pem -n openshift-ingress
#oc patch apiserver cluster --type=merge \
#  -p '{"spec":{"servingCerts": {"namedCertificates":[{"names": ["api.dan.danclark.io"], "servingCertificate": {"name": "api-certs"}}]}}}'

