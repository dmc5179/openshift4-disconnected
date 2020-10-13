#!/bin/bash

  
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Source the environment file with the default settings
source "${SCRIPT_DIR}/../env.sh"

${OC} extract secret/pull-secret -n openshift-config --to=.

jq 'del(.auths["cloud.openshift.com"])' .dockerconfigjson > .dockerconfigjson.tmp
mv .dockerconfigjson.tmp .dockerconfigjson

${OC} set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=.dockerconfigjson

rm -f .dockerconfigjson
