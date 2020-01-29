#!/bin/bash
#set -x

curl -s 'https://quay.io/cnr/api/v1/packages?namespace=redhat-operators' > redhat-operators.json
curl -s 'https://quay.io/cnr/api/v1/packages?namespace=community-operators' >> community-operators.json
curl -s 'https://quay.io/cnr/api/v1/packages?namespace=certified-operators' >> certified-operators.json

for src in redhat-operators.json community-operators.json certified-operators.json
do

  ops=$(jq '.[] | .name' "$src" | wc -l)

  for i in $(seq 0 $(expr $ops - 1))
  do

    NAME=$(jq ".[${i}] | .name " "$src" | tr -d '"')
    SHORT_NAME=$(echo "$NAME" | awk -F\/ '{print $2}')
    echo "Name: ${NAME}"
    echo "Short Name: ${SHORT_NAME}"
    RELEASE=$(jq ".[${i}] | .releases[0] " "$src" | tr -d '"')
    echo "Release: ${RELEASE}"
    DIGEST=$(curl -s "https://quay.io/cnr/api/v1/packages/${NAME}/${RELEASE}" | jq '.[0].content.digest' | tr -d '"')
    echo "Digest: ${DIGEST}"
    curl -s -XGET "https://quay.io/cnr/api/v1/packages/${NAME}/blobs/sha256/${DIGEST}" -o "${SHORT_NAME}.tar.gz"

    mkdir -p "manifests/${SHORT_NAME}"
    tar xzf "${SHORT_NAME}.tar.gz" -C "manifests/${SHORT_NAME}" --strip-components 1

  done

done

exit 0

