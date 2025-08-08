#!/bin/bash -xe

# Not required when using Simple Content Access Mode
#subscription-manager list --available --matches '*OpenShift*' 2>&1 > pools.txt
#subscription-manager attach --pool=<pool_id>

subscription-manager repos --disable="*"

subscription-manager repos \
    --enable="rhel-9-for-x86_64-baseos-rpms" \
    --enable="rhel-9-for-x86_64-appstream-rpms" \
    --enable="rhocp-4.18-for-rhel-9-x86_64-rpms" \
    --enable="fast-datapath-for-rhel-9-x86_64-rpms"

subscription-manager repos \
    --enable="rhel-8-for-x86_64-baseos-rpms" \
    --enable="rhel-8-for-x86_64-appstream-rpms" \
    --enable="rhocp-4.18-for-rhel-8-x86_64-rpms" \
    --enable="fast-datapath-for-rhel-8-x86_64-rpms"

#subscription-manager repos --enable=service-interconnect-_<version>_-for-rhel-8-x86_64-rpms
subscription-manager repos --enable=service-interconnect-1-for-rhel-8-x86_64-rpms


systemctl stop firewalld || true
systemctl disable --now firewalld.service || true

dnf module enable container-tools:rhel8

