#!/bin/bash -xe

# Source the environment file with the default settings
. ./env.sh


# NOTE: IGNITION VERSIONS in the USER DATA
# 4.2/4.3/4.4 = 2.1.0
# 4.5 = 2.2.0
# 4.6 = 3.1.0


# Check if the security group exists already.
K8S_MASTER_SG=$(aws --endpoint-url "${EC2_ENDPOINT}" ${AWS_OPTS} ec2 describe-security-groups \
  | jq '.SecurityGroups[] | select(.GroupName == "caas-k8s-master") | .GroupId' | tr -d '"')

# Check if the security group exists already.
K8S_WORKER_SG=$(aws --endpoint-url "${EC2_ENDPOINT}" ${AWS_OPTS} ec2 describe-security-groups \
  | jq '.SecurityGroups[] | select(.GroupName == "caas-k8s-worker") | .GroupId' | tr -d '"')

# AWS CLI to launch bootstrap node
BOOTSTRAP_INSTANCE_ID=$(aws --endpoint-url "${EC2_ENDPOINT}" ${AWS_OPTS} ec2 run-instances --image-id "${AMI}" --count 1 --instance-type 'i3.large' \
--key-name 'Combine' --subnet-id "${EC2_SUBNET}" --security-group-ids "${K8S_MASTER_SG}" --ebs-optimized \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=caas-bootstrap}]' --private-ip-address "${BOOTSTRAP_IP}" \
--user-data '{"ignition":{"config":{"replace":{"source":"http://10.0.106.109:8080/ignition/bootstrap.ign","verification":{}}},"timeouts":{},"version":"2.2.0"},"networkd":{},"passwd":{},"storage":{},"systemd":{}}' | jq '.Instances[0].InstanceId' | tr -d '"')

aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
      elb register-instances-with-load-balancer --load-balancer-name "${OCP_CLUSTER_NAME}-ingress" --instances "${BOOTSTRAP_INSTANCE_ID}"

# AWS CLI to launch master0
MASTER0_INSTANCE_ID=$(aws --endpoint-url "${EC2_ENDPOINT}" ${AWS_OPTS} ec2 run-instances --image-id "${AMI}" --count 1 --instance-type 'm5.2xlarge' \
--key-name 'Combine' --subnet-id "${EC2_SUBNET}" --security-group-ids "${K8S_MASTER_SG}" --ebs-optimized \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=caas-master0}]' --private-ip-address "${MASTER0_IP}" \
--user-data '{"ignition":{"config":{"replace":{"source":"http://10.0.106.109:8080/ignition/master0.ign","verification":{}}},"timeouts":{},"version":"2.2.0"},"networkd":{},"passwd":{},"storage":{},"systemd":{}}' | jq '.Instances[0].InstanceId' | tr -d '"')

# AWS CLI to launch master1
MASTER1_INSTANCE_ID=$(aws --endpoint-url "${EC2_ENDPOINT}" ${AWS_OPTS} ec2 run-instances --image-id "${AMI}" --count 1 --instance-type 'm5.2xlarge' \
--key-name 'Combine' --subnet-id "${EC2_SUBNET}" --security-group-ids "${K8S_MASTER_SG}" --ebs-optimized \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=caas-master1}]' --private-ip-address "${MASTER1_IP}" \
--user-data '{"ignition":{"config":{"replace":{"source":"http://10.0.106.109:8080/ignition/master1.ign","verification":{}}},"timeouts":{},"version":"2.2.0"},"networkd":{},"passwd":{},"storage":{},"systemd":{}}' | jq '.Instances[0].InstanceId' | tr -d '"')

# AWS CLI to launch master2
MASTER2_INSTANCE_ID=$(aws --endpoint-url "${EC2_ENDPOINT}" ${AWS_OPTS} ec2 run-instances --image-id "${AMI}" --count 1 --instance-type 'm5.2xlarge' \
--key-name 'Combine' --subnet-id "${EC2_SUBNET}" --security-group-ids "${K8S_MASTER_SG}" --ebs-optimized \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=caas-master2}]' --private-ip-address "${MASTER2_IP}" \
--user-data '{"ignition":{"config":{"replace":{"source":"http://10.0.106.109:8080/ignition/master2.ign","verification":{}}},"timeouts":{},"version":"2.2.0"},"networkd":{},"passwd":{},"storage":{},"systemd":{}}' | jq '.Instances[0].InstanceId' | tr -d '"')


# Notes on adding workers -----
# When the manifests were generated the worker count was set to 0 because the installer will not create them for us
# When you launch the instances below they will all spin around saying they don't know who they are
# This is because their CSRs have to be approved. After launching the instances start running 'oc get csr'
# and look for Pending CSRs to appear. You can approve them with 'oc adm certificate approve <first column of 'oc get csr'>


# AWS CLI to launch worker0
WORKER0_INSTANCE_ID=$(aws --endpoint-url "${EC2_ENDPOINT}" ${AWS_OPTS} ec2 run-instances --image-id "${AMI}" --count 1 --instance-type 'm5.2xlarge' \
--key-name 'Combine' --subnet-id "${EC2_SUBNET}" --security-group-ids "${K8S_WORKER_SG}" --ebs-optimized \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=caas-worker0}]' --private-ip-address "${WORKER0_IP}" \
--user-data '{"ignition":{"config":{"replace":{"source":"http://10.0.106.109:8080/ignition/worker0.ign","verification":{}}},"timeouts":{},"version":"2.2.0"},"networkd":{},"passwd":{},"storage":{},"systemd":{}}' | jq '.Instances[0].InstanceId' | tr -d '"')

# AWS CLI to launch worker1
WORKER1_INSTANCE_ID=$(aws --endpoint-url "${EC2_ENDPOINT}" ${AWS_OPTS} ec2 run-instances --image-id "${AMI}" --count 1 --instance-type 'm5.2xlarge' \
--key-name 'Combine' --subnet-id "${EC2_SUBNET}" --security-group-ids "${K8S_WORKER_SG}" --ebs-optimized \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=caas-worker1}]' --private-ip-address "${WORKER1_IP}" \
--user-data '{"ignition":{"config":{"replace":{"source":"http://10.0.106.109:8080/ignition/worker1.ign","verification":{}}},"timeouts":{},"version":"2.2.0"},"networkd":{},"passwd":{},"storage":{},"systemd":{}}' | jq '.Instances[0].InstanceId' | tr -d '"')

# AWS CLI to launch worker2
WORKER2_INSTANCE_ID=$(aws --endpoint-url "${EC2_ENDPOINT}" ${AWS_OPTS} ec2 run-instances --image-id "${AMI}" --count 1 --instance-type 'm5.2xlarge' \
--key-name 'Combine' --subnet-id "${EC2_SUBNET}" --security-group-ids "${K8S_WORKER_SG}" --ebs-optimized \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=caas-worker2}]' --private-ip-address "${WORKER2_IP}" \
--user-data '{"ignition":{"config":{"replace":{"source":"http://10.0.106.109:8080/ignition/worker2.ign","verification":{}}},"timeouts":{},"version":"2.2.0"},"networkd":{},"passwd":{},"storage":{},"systemd":{}}' | jq '.Instances[0].InstanceId' | tr -d '"')

aws --endpoint-url "${ELB_ENDPOINT}" ${AWS_OPTS} \
      elb register-instances-with-load-balancer --load-balancer-name "${OCP_CLUSTER_NAME}-ingress" --instances \
      "${MASTER0_INSTANCE_ID}" "${MASTER1_INSTANCE_ID}" "${MASTER2_INSTANCE_ID}" \
      "${WORKER0_INSTANCE_ID}" "${WORKER1_INSTANCE_ID}" "${WORKER2_INSTANCE_ID}"

exit 0
