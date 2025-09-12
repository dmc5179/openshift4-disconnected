# OpenShift IAM policy and user to install cluster

- The goal of this CF template is to create an IAM policy and user with the powers to install an OpenShift cluster in AWS

- During cluster install, the cluster will create least privilege policies for the 5 operators and the cluster itself.

- The API keys from this CF template will not be in the OpenShift cluster. Only used during install.

- Once the cluster is installed, deactivate the API keys in the web console and delete the CF template stack

- Use this file: cluster-creator-iam-role-cf-template.yaml
