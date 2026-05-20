# Red Hat Devspaces Disconnected 
- Red Hat OpenShift Dev Spaces is a web-based, collaborative integrated development environment (IDE) that is specifically optimized for OpenShift. It provides consistent, pre-configured, and secure container-based developer workspaces, eliminating "it works on my machine" issues by standardizing environments. 

- To improve developer experience recommend deploying the kubernetes imagepuller operator from the community index.  The operator essentially automates the proces of "pre-pulling" images identified to all worker nodes thus reducing the time to start a devspaces workspace. 


- To provide an internet connected feel for devspaces there are a couple of things that need to be created / pulled from an internet facing system
  - Build plugin repo
  - Build sample devfile repo (optional, recommended for inital setup)
  - devspaces and devworkspace-operator

## Build the plugin repo you will need to have podman, git and yarn installed
```console
sudo dnf install podman yarn git -y
```

- Clone repo and update openvsx-sync.json file and build, depending on the number of plugins it could take several minutes to build
```console
git clone https://github.com/redhat-developer/che-plugin-registry.git

cd che-plugin-registry 

vim openvsx-sync.json  #optional if you want to add / remove plugins

./build.sh
```

- Image quay.io/eclipse/che-plugin-registry:next will be created
```console
podman images
```

- Save index image to tarball for export to disconnected environment
```console
podman save quay.io/eclipse/che-plugin-registry:next > che-plugin-registry-next.tar
```

## Build sample template devfiles image 
- Clone repo, update stack directory and build, depending on the number of sample templates in stack directory it could take a couple minutes to build
NOTE: We will need to add the image from each devfile.yaml to additionalImages in the imageset-config so the workspace can launch.  Recommendation for the platform and developers to sync on workspaces requried. 
```console
git clone https://github.com/devfile/registry.git

export USE_PODMAN=true

# Add/Remove sample templates from stack directory.  

bash .ci/build.sh linux/amd64 offline
```

- Save index image to tarball for export to disconnected environment
```console
podman save localhost/devfile-index:latest > devfile-index-latest.tar
```

- Copy repo needed to deploy devfile registry
``` console
git clone https://github.com/devfile/registry-support.git

tar -cvf registry-support-repo.tgz registry-support/*
```

## Need to pull the following content from an internet connected machine
- Add the following to the redhat-registry-index section in imageset-config.yaml
```yaml
  additionalImages:
    - name: <image in devfile for stack>  
    - name: <image in devfile for stack>
    - name: <image in devfile for stack>
  operators:
    # Red Hat Operator Index Catalog
    - catalog: registry.redhat.io/redhat/redhat-operator-index:v4.20
      packages:
        - name: devspaces
          channels:
            - name: stable
        - name: devworkspace-operator
          channels:
            - name: fast
```

## Checklist to transfer to disconnected network
  - imageset-config.yaml
  - d2m mirror_seq_XXXXX.tar
  - che-plugin-registry-next.tar
  - registry-support-repo.tgz 
  - devfile-index-latest.tar

## Disconnected Openshift Cluster Actions
- Disk-2-Mirror the images using oc-mirror
- Deploy the devspaces operator via gui - devworkspace-operator gets installed automatically

- Push the devfile image to local repo 
```console
podman load --input devfile-index-latest.tar 

podman tag localhost/devfile-index:latest <internal-registry-fqdn>:8443/devfile-index:latest

podman push <internal-registry-fqdn>:8443/devfile-index:latest
```

- Push the plugin registry image to local repo
```console
podman load --input devfile-index-latest.tar

podman tag quay.io/eclipse/che-plugin-registry:next <internal-registry-fqdn>:8443/eclipse/che-plugin-registry:next

podman push <internal-registry-fqdn>:8443/eclipse/che-plugin-registry:next
```

- Install Devspaces Operator via Gui Ecosystem -> Software Catalog -> Red Hat OpenShift Dev Spaces -> Install (keep defaults).  You should notice that the DevWorkspace Operator gets installed at the sametime Dev Spaces operator is installed

- Create OpenShift project devspaces
```console
oc new-project devspaces
```

- Create CheCluster via GUI, Ecosystem -> Installed Operators -> DevSpaces -> Create instance.   NOTE: Ensure project is set to devspaces namesapce and keep defaults

- Deploy the devfile registry
```console
tar -xvf registry-support-repo.tgz

cd registry-support-repo
bash ./helm-openshift-install.sh --set devfileIndex.image=<interal-registry-fqdn:port>/library/devfile-index --set devfileIndex.tag=latest
```

- Once complete update the cheCluster devspaces CR with the route
```console
oc get route 

oc patch checluster devspaces --type='merge' -p '{"spec": {"components": {"devfileRegistry": {"externalDevfileRegistries": [{"url": "http://<devfile-registry route>"}]}}}}'
```

- Update pluginRegistry repo
```console
oc patch checluster devspaces --type='merge' -p '{"spec": {"components": {"pluginRegistry": {"deployment": {"containers": [{"image": "<registry-fqdn:port>/eclipse/che-plugin-registry:next"}]}}}}}'
```

- VS Code expects the plugins to be from a public repo, developers will not be able to install the plugins due to a signature error.  To resolve this in a once-and-done setting apply the following path to the checluster
```console
oc patch checluster devspaces -n openshift-devspaces --type='json' -p='[
  {
    "op": "add",
    "path": "/spec/components/cheServer/extraProperties/CHE_WORKSPACE_ENGINE_WORKSPACE_DEFAULT__EDITOR__LAUNCHER__ARGS",
    "value": "--disable-extensions-signature-verification"
  }
]'
```

## Configure the number of devspaces instances for a user:
- By default a devuser can have an unlimited number of workspaces but only 1 workspace running at a time.  The following section will help you configure the number of workpsaces and running workspaces allowed per user.

- Get the number of workspaces a user can have.  A -1 indicates unlimited
```console
oc get checluster/devspaces -n devspaces -o jsonpath='{.spec.devEnvironments.maxNumberOfWorkspacesPerUser}'
```

- Get the number of workspaces a user can have, defualt is 1.  If there no value is returned then 1 running devsapce per user
```console
oc get checluster/devspaces -n devspaces -o jsonpath='{.spec.devEnvironments.maxNumberOfRunningWorkspacesPerUser}'
```

- Set the number of workspaces a user can have.
```console
oc patch checluster/devspaces -n devspaces --type='merge' -p '{"spec":{"devEnvironments":{"maxNumberOfWorkspacesPerUser": 3}}}'
```

- Set the number of running workspaces a user can have.
```console
oc patch checluster/devspaces -n devspaces --type='merge' -p '{"spec":{"devEnvironments":{"maxNumberOfRunningWorkspacesPerUser": 3}}}'
```
