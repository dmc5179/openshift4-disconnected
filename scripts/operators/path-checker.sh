#!/bin/bash

# Name, channel, and versions should come from a command like this
# --v1 list operators --catalog=registry.redhat.io/redhat/redhat-operator-index:v4.20 --package=kubevirt-hyperconverged --channel=stable

OPERATOR_NAME="kubevirt-hyperconverged"
OPERATOR_CHANNEL="stable"
CURRENT_VERSION="4.18.3"
DESIRED_VERSION="4.20.8"


opm render --output json registry.redhat.io/redhat/redhat-operator-index:v4.18 > opm-render-rh-op-index-v418.json
opm render --output json registry.redhat.io/redhat/redhat-operator-index:v4.19 > opm-render-rh-op-index-v419.json
opm render --output json registry.redhat.io/redhat/redhat-operator-index:v4.20 > opm-render-rh-op-index-v420.json



#jq -s '.[] | select( .schema == "olm.channel" ) | select ( .name == "stable") | select( .package == "kubevirt-hyperconverged")' ./opm-rh-op-index.txt 

jq --arg channel "${OPERATOR_CHANNEL}" --arg package "${OPERATOR_NAME}" --arg ver "${DESIRED_VERSION}"  -s '.[] | select( .schema == "olm.channel" ) | select ( .name == $channel) | select( .package == $package).entries[] | select(.name | contains($ver))' opm-render-rh-op-index-v420.json
