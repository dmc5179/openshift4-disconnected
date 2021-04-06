#!/bin/bash 

#set -x

#############################################################
export OCP_MEDIA_PATH=/opt/data/openshift
mkdir -p "${OCP_MEDIA_PATH}/community-operators"

opm index export \
  --index=registry.redhat.io/redhat/community-operator-index:latest  --download-folder "${OCP_MEDIA_PATH}/community-operators"

for d in $(find "${OCP_MEDIA_PATH}/community-operators/" -type d -maxdepth 1 | tail -n +2)
do

  echo "check dir: ${d}"

  CHANNEL=$(yq -r '.defaultChannel' "${d}/package.yaml")
  VER=$(yq -r ".channels[] | select(.name == \"${CHANNEL}\") | .currentCSV" ${d}/package.yaml)

  NAME=$(basename "${d}")

  DIR=$(echo "${VER}" | cut -d '.' -f2- | tr -d 'v')

  echo "channel: $CHANNEL, ver: $VER, name: $NAME, dir: $DIR"

  for f in $(find "${d}/${DIR}" -name "*clusterserviceversion.yaml")
  do

#TODO: This is the part the doesn't work on community operators because
#      most do not have the "relatedImages" field
#    if [[ $(yq -r ".metadata.name" "${f}") == "${VER}" ]]
#    then
#      yq -r '.spec.relatedImages[] | .image' "${f}"
#    fi
  done


done

exit 0
