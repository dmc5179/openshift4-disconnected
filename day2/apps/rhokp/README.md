# Red Hat Offline Knowledge Portal

## Obtain Access Key

- Follow the steps here to get your access key

https://docs.redhat.com/en/documentation/red_hat_offline_knowledge_portal/1/html/user_guide/proc_launching-rhokp

## Deploying the container with podman

. Run the container

```console
export RHOKP_KEY="key from RHN"

podman run --rm -p 8080:8080 -p 8443:8443 \
--env "ACCESS_KEY=${RHOKP_KEY}" \
-d registry.redhat.io/offline-knowledge-portal/rhokp-rhel9:latest
```

## Deploy the RHOKP to OpenShift

- Update the deployment yaml with your access key. The key will need to be base64 encoded like;

```console
echo 'key from RHN' | base64 -w 0
```

- Create a new namespace
```console
oc new-project rhokp
```

- Deploy RHOKP
```console
oc create -f rhokp-deployment.yaml
```

