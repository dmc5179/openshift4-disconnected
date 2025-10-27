#!/bin/bash

MAPPING_FILE="../../v1/sequential-runs/oc-mirror-workspace/results-1757018271/mapping.txt"

RELEASE_IMAGES=$(cat "${MAPPING_FILE}" | awk -F\= '{print $1}')

cp -f pinned-imageset-template.yaml pinned-imageset.yaml

while IFS= read -r line; do
  IMAGE=$(echo "${line}" | awk -F\= '{print $1}')
  yq -i ".spec.pinnedImages += {\"name\": \"${IMAGE}\"}" pinned-imageset.yaml
done < "$MAPPING_FILE"
