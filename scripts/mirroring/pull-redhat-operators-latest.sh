#!/bin/bash -e
  
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Source the environment file with the default settings
source "${SCRIPT_DIR}/../env.sh"

set -x

mkdir -p "${OCP_MEDIA_PATH}/redhat_operators_opm"

opm index export \
    --index=registry.redhat.io/redhat/redhat-operator-index:v4.6 \
    --download-folder "${OCP_MEDIA_PATH}/redhat_operators_opm"

for o in $(find "${OCP_MEDIA_PATH}/redhat_operators_opm" -maxdepth 1 -type d | tail -n +2)
do

  CHANNEL=$(yq -r '.defaultChannel' "${o}/package.yaml")
  VER=$(yq -r ".channels[] | select(.name==\"${CHANNEL}\") | .currentCSV" "${o}/package.yaml")

  for f in $(find "${o}" -name "*clusterserviceversion.yaml")
  do
    if [[ $(yq -r ".metadata.name" "${f}") == "${VER}" ]]
    then
      yq -r '.spec.relatedImages[] | .image' "${f}"
    fi
  done
done

