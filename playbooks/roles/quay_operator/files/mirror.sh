#!/bin/bash -xe

# Make sure to follow this article for credentials used to pull the main quay images
# https://access.redhat.com/solutions/3533201

LOCAL_SECRET_JSON='/run/user/1000/containers/auth.json'
REMOTE_REG='registry.example.com:5000'

# Quay Version 3.something
#oc image mirror --force --filter-by-os=.* --keep-manifest-list=true --registry-config "${LOCAL_SECRET_JSON}" --insecure=true 'registry.redhat.io/quay/quay-rhel8-operator@sha256:632f293ce63f89eddbbe4b769c3af166b72f6a0ddca66bd7a183df0f74ad9de8' "${REMOTE_REG}/quay/quay-rhel8-operator"

#oc image mirror --registry-config "${LOCAL_SECRET_JSON}" --insecure=true registry.access.redhat.com/rhscl/redis-32-rhel7:latest "${REMOTE_REG}/rhscl/redis-32-rhel7:latest"

#oc image mirror --registry-config "${LOCAL_SECRET_JSON}" --insecure=true registry.access.redhat.com/rhscl/postgresql-96-rhel7:1 "${REMOTE_REG}/rhscl/postgresql-96-rhel7:1"


#oc image mirror --registry-config "${LOCAL_SECRET_JSON}" --insecure=true quay.io/projectquay/quay:qui-gon "${REMOTE_REG}/projectquay/quay:qui-gon"
#oc image mirror --registry-config "${LOCAL_SECRET_JSON}" --insecure=true quay.io/projectquay/clair-jwt:qui-gon "${REMOTE_REG}/projectquay/clair-jwt:qui-gon"



# Version 3.3.0 images

oc image mirror --force --filter-by-os=.* --keep-manifest-list=true --registry-config ${LOCAL_SECRET_JSON} --insecure=true 'quay.io/redhat/quay@sha256:2218711b5d34b1f68ebeeb71fca76546acb9625ef8f1ad493e8dd6a8e89b9838' "${REMOTE_REG}/redhat/quay"

exit 0
oc image mirror --force --filter-by-os=.* --keep-manifest-list=true --registry-config "${LOCAL_SECRET_JSON}" --insecure=true 'registry.redhat.io/quay/quay-rhel8-operator@sha256:855743b29f8e050fb1f124b47f622b9e179998df60ad9465b51553f1c729197d' "${REMOTE_REG}/quay/quay-rhel8-operator"

oc image mirror --force --filter-by-os=.* --keep-manifest-list=true --registry-config "${LOCAL_SECRET_JSON}" --insecure=true 'registry.redhat.io/rhel8/redis-5@sha256:ee07b7d2113fd819b183f01c134dff13c8cfe965669f330a6e384791f8ac3d4e' "${REMOTE_REG}/rhel8/redis-5"

oc image mirror --force --filter-by-os=.* --keep-manifest-list=true --registry-config "${LOCAL_SECRET_JSON}" --insecure=true 'registry.redhat.io/rhel8/postgresql-96@sha256:e2f16336f000f5c89d5d431a067a6c43c601789e801daee69a12c0871640969f' "${REMOTE_REG}/rhel8/postgresql-96"


