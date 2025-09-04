#!/bin/bash

export MCH_NAMESPACE=open-cluster-management

oc patch multiclusterhubs.operator.open-cluster-management.io multiclusterhub -n ${MCH_NAMESPACE} --type json --patch '[{"op": "add", "path":"/spec/overrides/components/-", "value": {"name":"siteconfig","enabled": true}}]'

oc -n ${MCH_NAMESPACE} get po | grep siteconfig

oc -n ${MCH_NAMESPACE} get cm
