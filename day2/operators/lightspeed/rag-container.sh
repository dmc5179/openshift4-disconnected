#!/bin/bash

podman run -it --rm --device=/dev/fuse \
  -v $XDG_RUNTIME_DIR/containers/auth.json:/run/user/0/containers/auth.json:Z \
  -v <dir_tree_with_markdown_files>:/markdown:Z \
  -v <dir_for_image_tar>:/output:Z \
  registry.redhat.io/openshift-lightspeed-tech-preview/lightspeed-rag-tool-rhel9:latest

# Change container above to have markdownify
#
# gzip -dfc <file> | markdownify > /path/to/out.md
#
# Files located in /var/www/html in the RHOKP container
