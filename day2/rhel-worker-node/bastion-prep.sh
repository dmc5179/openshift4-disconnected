#!/bin/bash -e

# Used to install packages onto the node that will run
# the ansible playbooks to add the rhel worker node
# to the cluster

OCP_VER=4.18
RHEL_VER="x"

if grep -q 'release 9' /etc/redhat-release
then
  RHEL_VER="9"
elif grep -q 'release 8' /etc/redhat-release
then
  RHEL_VER="8"
else
  echo "Unable to determine RHEL major release version"
  exit 1
fi

subscription-manager repos \
    --enable="rhel-${RHEL_VER}-for-x86_64-baseos-rpms" \
    --enable="rhel-${RHEL_VER}-for-x86_64-appstream-rpms" \
    --enable="rhocp-${OCP_VER}-for-rhel-${RHEL_VER}-x86_64-rpms"
