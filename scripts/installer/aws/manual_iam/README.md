# Steps to manually generate AWS IAM roles and have the cluster installer use them during IPI

- To generate the IAM policy files run:
```
./generate_iam_policy.sh
```

- To create the IAM users, policies, attach the policies, and create API keys run:
```
./create_iam_roles.sh
```

- To generate the manifests for installing the OpenShift cluster in GovCloud run:
```
manual_iam_mode.sh
```

- Run the openshift-install command as normal:
```
openshift-install create cluster --dir /home/ec2-user/workspace/openshift4-disconnected/scripts/installer/aws/govcloud/cluster/ --log-level=debug
```
