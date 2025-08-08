#!/bin/bash -xe


subscription-manager repos \
    --enable="rhel-9-for-x86_64-baseos-rpms" \
    --enable="rhel-9-for-x86_64-appstream-rpms" \
    --enable="rhocp-4.18-for-rhel-9-x86_64-rpms"

