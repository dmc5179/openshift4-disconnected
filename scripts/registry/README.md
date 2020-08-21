
# Mirror from local registry to ECR

## Variable file

- Copy the env.sh.example file to env.sh and edit the variables as described below

| Variable                                        | Default                                                       | Comments                        |
| :---                                            | :---                                                          | :---                            |
| OCP_RELEASE                                     | "4.5.1-x86_64"                                                |                                 |
| LOCAL_REG                                       | 'localhost:5000'                                              |                                 |
| LOCAL_REPO                                      | 'ocp4/openshift4'                                             |                                 |
| LOCAL_REG_INSEC                                 | 'true'                                                        |                                 |
| UPSTREAM_REPO                                   | 'openshift-release-dev'                                       |                                 |
| OCP_ARCH                                        | "x86_64"                                                      |                                 |
| REMOVABLE_MEDIA_PATH                            | "/tmp/ocp-${OCP_RELEASE}"                                     |                                 |
| REMOTE_REG                                      | "localhost:5000"                                              |                                 |
| LOCAL_SECRET_JSON                               | "${HOME}/pull-secret.json"                                    |                                 |
| RELEASE_NAME                                    | "ocp-release"                                                 |                                 |
| RH_OP                                           | 'true'                                                        |                                 |
| CERT_OP                                         | 'false'                                                       |                                 |
| COMM_OP                                         | 'false'                                                       |                                 |
| RH_OP_REPO                                      | "${LOCAL_REG}/olm/redhat-operators:v1"                        |                                 |
| CERT_OP_REPO                                    | "${LOCAL_REG}/olm/certified-operators:v1"                     |                                 |
| COMM_OP_REPO                                    | "${LOCAL_REG}/olm/community-operators:v1"                     |                                 |
| OPERATOR_REGISTRY                               | 'quay.io/operator-framework/operator-registry-server:v1.13.6' |                                 |
| DATA_DIR                                        | "/opt/registry/data/docker/"                                  |                                 |


## Helpful commands

 - This command will take the images from a local docker registry and mirror them into an ECR registry in AWS

 ```
 oc image mirror -a 'auth.json' --insecure=true '<local registry: port>/ocp4/openshift4:4.5.6*' '123456789.dkr.ecr.us-east-1.amazonaws.com/ocp4/openshift4'
 ```