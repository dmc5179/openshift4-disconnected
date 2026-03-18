# Red Hat Offline Knowledge Portal

## Obtain RHOKP_KEY from RHN

RHOKP requires an access key from your RHN account to unlock the content inside of the ROKP container

## Deploying the container with podman

. Run the container

```console
export RHOKP_KEY="key from RHN"

podman run --rm -p 8080:8080 -p 8443:8443 \
--env "ACCESS_KEY=${RHOKP_KEY}" \
-d registry.redhat.io/offline-knowledge-portal/rhokp-rhel9:latest
```

## Deploying the container on OpenShift

. Update the rhokp-deployment.yaml with the access key from RHN

. Deploy the RHOKP container into OpenShift

```console
oc create -f rhokp-deployment.yaml
```

