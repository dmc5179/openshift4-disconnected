#!/bin/bash
  
# Source the environment file with the default settings
. ./env.sh

if [ "${RH_OP}" = true ]
then

  oc apply -f redhat-operators-manifests/imageContentSourcePolicy.yaml

  oc image mirror --filename redhat-operators-manifests/mapping.txt

  sed "s/REGISTRY/${REMOTE_REG}/" redhat-operators-catalogsource.yaml | oc apply -f -

fi

if [ "${CERT_OP}" = true ]
then

  oc apply -f certified-operators-manifests/imageContentSourcePolicy.yaml

  oc image mirror --filename certified-operators-manifests/mapping.txt

  sed "s/REGISTRY/${REMOTE_REG}/" certified-operators-catalogsource.yaml | oc apply -f -

fi

if [ "${COMM_OP}" = true ]
then

  oc apply -f community-operators-manifests/imageContentSourcePolicy.yaml

  oc image mirror --filename community-operators-manifests/mapping.txt

  sed "s/REGISTRY/${REMOTE_REG}/" community-operators-catalogsource.yaml | oc apply -f -

fi

exit 0
