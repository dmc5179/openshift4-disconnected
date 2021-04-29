#!/bin/bash

# Check for jq and exit if missing
if [[ ! `which jq 2>/dev/null` ]]
then
  echo "Please install jq using pip or yum"
  exit 1
fi

oc extract secret/pull-secret -n openshift-config --to=.

jq 'del(.auths["cloud.openshift.com"])' .dockerconfigjson > .dockerconfigjson.tmp

mv .dockerconfigjson.tmp .dockerconfigjson

oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=.dockerconfigjson

rm -f .dockerconfigjson
