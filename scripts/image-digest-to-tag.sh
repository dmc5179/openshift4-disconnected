#!/bin/bash

# Define your variables
REPO="docker://registry.redhat.io/rhoai/odh-workbench-jupyter-minimal-cpu-py311-rhel9"
TARGET_DIGEST="sha256:2b00a5b676b07d4fd6ab894d5dcaeb5bf88ef35bde76cbf3b4c0951987e5aad6" # Replace with your digest

skopeo list-tags $REPO | jq -r '.Tags[]' | xargs -I {} sh -c '
  DIGEST=$(skopeo inspect --no-tags '$REPO':{} --format "{{.Digest}}")
  if [ "$DIGEST" = "'$TARGET_DIGEST'" ]; then
    echo "Match found: {}"
  fi
'

exit 0

# Make it faster
REPO="docker://docker.io/library/nginx"
TARGET_DIGEST="sha256:b555f8c64cf4e221"

skopeo list-tags $REPO | jq -r '.Tags[]' | \
parallel -j 10 "echo -n '{}: ' && skopeo inspect --no-tags $REPO:{} --format '{{.Digest}}'" | \
grep "$TARGET_DIGEST"

# Use crane instead

REPO="docker://docker.io/library/nginx"
TARGET_DIGEST="sha256:b555f8c64cf4e221"

crane list-tags $REPO | jq -r '.Tags[]' | \
parallel -j 10 "echo -n '{}: ' && crane inspect --no-tags $REPO:{} --format '{{.Digest}}'" | \
grep "$TARGET_DIGEST"
