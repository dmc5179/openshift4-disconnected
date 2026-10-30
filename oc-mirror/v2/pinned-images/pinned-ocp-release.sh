#!/bin/bash

# Usage: pinned-ocp-release.sh <mapping.txt>
# mapping.txt comes from an oc-mirror v1 run (oc-mirror-workspace/results-*/mapping.txt).
MAPPING_FILE="${1:?Usage: $0 <oc-mirror v1 mapping.txt>}"

RELEASE_IMAGES=$(cat "${MAPPING_FILE}" | awk -F\= '{print $1}')

cp -f pinned-imageset-template.yaml pinned-imageset.yaml

while IFS= read -r line; do
  IMAGE=$(echo "${line}" | awk -F\= '{print $1}')
  yq -i ".spec.pinnedImages += {\"name\": \"${IMAGE}\"}" pinned-imageset.yaml
done < "$MAPPING_FILE"
