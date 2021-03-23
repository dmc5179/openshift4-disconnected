#!/bin/bash

#oc create secret tls api-cert --cert=/home/danclark/openshift_clusters/aws_certs/cert.pem --key=/home/danclark/openshift_clusters/aws_certs/key.pem -n openshift-config
#
#oc patch apiserver cluster --type=merge \
#  -p '{"spec":{"servingCerts": {"namedCertificates":[{"names": ["api.dan.danclark.io"], "servingCertificate": {"name": "api-cert"}}]}}}'
#
#oc create secret tls apps-cert --cert=/home/danclark/openshift_clusters/aws_certs/cert.pem --key=/home/danclark/openshift_clusters/aws_certs/key.pem -n openshift-ingress
#
#oc patch ingresscontroller.operator default  --type=merge \
#   -p  '{"spec":{"defaultCertificate": {"name": "apps-cert"}}}'  -n openshift-ingress-operator
#
#exit 0


#oc create secret tls api-certs --cert=/home/danclark/openshift_clusters/aws_certs/fullchain.pem --key=/home/danclark/openshift_clusters/aws_certs/key.pem -n openshift-ingress
oc create secret tls router-certs --cert=/home/danclark/openshift_clusters/aws_certs/fullchain.pem --key=/home/danclark/openshift_clusters/aws_certs/key.pem -n openshift-ingress
#oc patch apiserver cluster --type=merge \
#  -p '{"spec":{"servingCerts": {"namedCertificates":[{"names": ["api.dan.danclark.io"], "servingCertificate": {"name": "api-certs"}}]}}}'
oc patch ingresscontroller default -n openshift-ingress-operator --type=merge --patch='{"spec": { "defaultCertificate": { "name": "router-certs" }}}'

