#!/bin/bash -xe

# Not required when using Simple Content Access Mode
#subscription-manager list --available --matches '*OpenShift*' 2>&1 > pools.txt
#subscription-manager attach --pool=<pool_id>

OCP_VER="4.18"
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

subscription-manager repos --disable="*"

subscription-manager repos \
    --enable="rhel-${RHEL_VER}-for-x86_64-baseos-rpms" \
    --enable="rhel-${RHEL_VER}-for-x86_64-appstream-rpms" \
    --enable="rhocp-${OCP_VER}-for-rhel-${RHEL_VER}-x86_64-rpms" \
    --enable="fast-datapath-for-rhel-${RHEL_VER}-x86_64-rpms"

systemctl stop firewalld || true
systemctl disable --now firewalld.service || true

# There appears to be a bug in at least the RHEL 8 ansible playbooks where
# this needs to be enabled before running the scaleup playbook which disables
# this module too soon
dnf module enable "container-tools:rhel${RHEL_VER}"
