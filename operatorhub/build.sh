#!/bin/bash

oc adm catalog mirror \
    <registry_host_name>:<port>/olm/redhat-operators:v1 \
    <registry_host_name>:<port> \
    [-a <path_to_registry_credentials>] \
    [--insecure]

# Export the image above and take it over to the air-gapped system

oc apply -f ./redhat-operators-manifests

oc create -f catalogsource.yaml
