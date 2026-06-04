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
