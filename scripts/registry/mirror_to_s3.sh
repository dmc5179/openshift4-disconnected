#!/bin/bash -x

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  
# Source the environment file with the default settings
source "${SCRIPT_DIR}/../env.sh"

S3_BUCKET='danclark-podman-registry'


# There appears to be a bug in how oc uploads to S3. You may see errors like this:
#error: unable to upload blob sha256:daefd6c4b0607ef2b5c6ffbf30f51ebf8eb9ff40ac205f5bbfd3b0ec558d6010 
#       to s3://s3.amazonaws.com/ocp-release: blob already exists in the target location
# The upload still works and the blob already exists so the error can be ignored.

${OC} adm release mirror -a ${LOCAL_SECRET_JSON} \
--insecure=${LOCAL_REG_INSEC} \
--from=quay.io/${UPSTREAM_REPO}/${RELEASE_NAME}:${OCP_RELEASE} \
--to=s3://${AWS_DEFAULT_REGION}/${S3_BUCKET}/mirror

# Example
#/usr/local/bin/oc adm release mirror -a /tmp/pull-secret.json --from=quay.io/openshift-release-dev/ocp-release:4.6.7-x86_64 --to=s3://s3.amazonaws.com/$region/${s3_bucket}/ocp-release || true
