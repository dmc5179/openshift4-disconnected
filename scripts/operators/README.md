
# Mirror OpenShift 4 OperatorHub Container Images

## Variable file

- Copy the env.sh.example file to env.sh and edit the variables as described below

| Variable                                        | Default                                                       | Comments                                                                                                 |
| :---                                            | :---                                                          | :---                                                                                                     |
| OCP_RELEASE                                     | "4.5.1-x86_64"                                                | OpenShift version                                                                                        |
| LOCAL_REG                                       | 'localhost:5000'                                              | Registry where the images will be pushed to                                                              |
| LOCAL_REPO                                      | 'ocp4/openshift4'                                             | Repository where the images will be pushed to                                                            |
| LOCAL_REG_INSEC                                 | 'true'                                                        | SSL secure registry option                                                                               |
| UPSTREAM_REPO                                   | 'openshift-release-dev'                                       | OpenShift release stream                                                                                 |
| OCP_ARCH                                        | "x86_64"                                                      | OpenShift Architecture                                                                                   |
| REMOVABLE_MEDIA_PATH                            | "/tmp/ocp-${OCP_RELEASE}"                                     | Local directory when mirroring to a directory                                                            |
| REMOTE_REG                                      | "localhost:5000"                                              | Registry where the images will be pushed to                                                              |
| LOCAL_SECRET_JSON                               | "${HOME}/pull-secret.json"                                    | Pull secret which contains auth tokens for both the OpenShift repos and the private repo                 |
| RELEASE_NAME                                    | "ocp-release"                                                 | OpenShift release stream                                                                                 |
| RH_OP                                           | 'true'                                                        | Mirror RedHat Operators                                                                                  |
| CERT_OP                                         | 'false'                                                       | Mirror Certified Operators                                                                               |
| COMM_OP                                         | 'false'                                                       | Mirror Community Operators                                                                               |
| RH_OP_REPO                                      | "${LOCAL_REG}/olm/redhat-operators:v1"                        | Location in private registry for RedHat Operator Catalog Source (generally don't need to change this)    |
| CERT_OP_REPO                                    | "${LOCAL_REG}/olm/certified-operators:v1"                     | Location in private registry for Certified Operator Catalog Source (generally don't need to change this) |
| COMM_OP_REPO                                    | "${LOCAL_REG}/olm/community-operators:v1"                     | Location in private registry for Community Operator Catalog Source (generally don't need to change this) |
| OPERATOR_REGISTRY                               | 'quay.io/operator-framework/operator-registry-server:v1.13.6' | Image to build the operator catalog images on top of (generally don't need to change this)               |
| DATA_DIR                                        | "/opt/registry/data/docker/"                                  | Local directory where the registry will be installed to if installing a private registry                 |

## Mirroring to a registry

### Creating your own local docker registry

- Create a podman registry by running the following script. (Note that this script uses sudo for some things)

```
./install_registry.sh
```

### Mirror the OpenShift Cluster Images

- Mirror the OpenShift cluster images to the registry set in env.sh

```
./mirror_to_registry.sh
```

### Build OpenShift OperatorHub Catalog Source Images

```

```

### Export OpenShift OperatorHub Catalog Source Images

```

```

## Helpful commands

 - This command will take the images from a local docker registry and mirror them into an ECR registry in AWS

 ```
 oc image mirror -a 'auth.json' --insecure=true '<local registry: port>/ocp4/openshift4:4.5.6*' '123456789.dkr.ecr.us-east-1.amazonaws.com/ocp4/openshift4'
 ```
