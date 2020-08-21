
# Mirror from local registry to ECR
# This command will take the images from a local docker registry and mirror them into an ECR registry in AWS
oc image mirror -a 'auth.json' --insecure=true '<local registry: port>/ocp4/openshift4:4.5.6*' '774207953476.dkr.ecr.us-east-1.amazonaws.com/ocp4/openshift4'

