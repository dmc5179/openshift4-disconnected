#!/bin/bash -xe

# Source the environment file with the default settings
. ./env.sh


# NOTE: IGNITION VERSIONS in the USER DATA
# 4.2/4.3/4.4 = 2.1.0
# 4.5 = 2.2.0
# 4.6 = 3.1.0


# Check if the security group exists already.
K8S_MASTER_SG=$(aws ${EC2_ENDPOINT} ${AWS_OPTS} ec2 describe-security-groups \
  | jq '.SecurityGroups[] | select(.GroupName == "caas-k8s-master") | .GroupId' | tr -d '"')

# Check if the security group exists already.
K8S_WORKER_SG=$(aws ${EC2_ENDPOINT} ${AWS_OPTS} ec2 describe-security-groups \
  | jq '.SecurityGroups[] | select(.GroupName == "caas-k8s-worker") | .GroupId' | tr -d '"')

USER_DATA=$(sed "s|IGN_SERVER|${IGN_SERVER}|" user-data-ign.json | sed "s|IGN_PATH|${IGN_PATH}|g" | sed "s|IGN_VERSION|${IGN_VERSION}|")

# Generate the base64 encoded user data for each ec2 instance
BOOTSTRAP_UD=$(echo "${USER_DATA}" | sed "s|HOST|bootstrap|")
MASTER0_UD=$(echo "${USER_DATA}" | sed "s|HOST|master0|")
MASTER1_UD=$(echo "${USER_DATA}" | sed "s|HOST|master1|")
MASTER2_UD=$(echo "${USER_DATA}" | sed "s|HOST|master2|")
WORKER0_UD=$(echo "${USER_DATA}" | sed "s|HOST|worker0|")
WORKER1_UD=$(echo "${USER_DATA}" | sed "s|HOST|worker1|")
WORKER2_UD=$(echo "${USER_DATA}" | sed "s|HOST|worker2|")

# AWS CLI to launch bootstrap node
BOOTSTRAP_INSTANCE_ID=$(aws ${EC2_ENDPOINT} ${AWS_OPTS} ec2 run-instances --image-id "${AMI}" --count 1 --instance-type 'i3.large' \
--key-name 'Combine' --subnet-id "${EC2_SUBNET}" --security-group-ids "${K8S_MASTER_SG}" --ebs-optimized \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=caas-bootstrap}]' --private-ip-address "${BOOTSTRAP_IP}" \
--block-device-mapping "DeviceName=/dev/xvda,Ebs={DeleteOnTermination=true,KmsKeyId=${KMS_KEY_ID},Encrypted=true}" \
--user-data "${BOOTSTRAP_UD}" | jq '.Instances[0].InstanceId' | tr -d '"')

aws ${ELB_ENDPOINT} ${AWS_OPTS} \
      elb register-instances-with-load-balancer --load-balancer-name "${OCP_CLUSTER_NAME}-ingress" --instances "${BOOTSTRAP_INSTANCE_ID}"

# AWS CLI to launch master0
MASTER0_INSTANCE_ID=$(aws ${EC2_ENDPOINT} ${AWS_OPTS} ec2 run-instances --image-id "${AMI}" --count 1 --instance-type 'm5.2xlarge' \
--key-name 'Combine' --subnet-id "${EC2_SUBNET}" --security-group-ids "${K8S_MASTER_SG}" --ebs-optimized \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=caas-master0}]' --private-ip-address "${MASTER0_IP}" \
--block-device-mapping "DeviceName=/dev/xvda,Ebs={DeleteOnTermination=true,VolumeSize=50,VolumeType=gp2,KmsKeyId=${KMS_KEY_ID},Encrypted=true}" \
--user-data "${MASTER0_UD}" | jq '.Instances[0].InstanceId' | tr -d '"')

# AWS CLI to launch master1
MASTER1_INSTANCE_ID=$(aws ${EC2_ENDPOINT} ${AWS_OPTS} ec2 run-instances --image-id "${AMI}" --count 1 --instance-type 'm5.2xlarge' \
--key-name 'Combine' --subnet-id "${EC2_SUBNET}" --security-group-ids "${K8S_MASTER_SG}" --ebs-optimized \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=caas-master1}]' --private-ip-address "${MASTER1_IP}" \
--block-device-mapping "DeviceName=/dev/xvda,Ebs={DeleteOnTermination=true,VolumeSize=50,VolumeType=gp2,KmsKeyId=${KMS_KEY_ID},Encrypted=true}" \
--user-data "${MASTER1_UD}" | jq '.Instances[0].InstanceId' | tr -d '"')

# AWS CLI to launch master2
MASTER2_INSTANCE_ID=$(aws ${EC2_ENDPOINT} ${AWS_OPTS} ec2 run-instances --image-id "${AMI}" --count 1 --instance-type 'm5.2xlarge' \
--key-name 'Combine' --subnet-id "${EC2_SUBNET}" --security-group-ids "${K8S_MASTER_SG}" --ebs-optimized \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=caas-master2}]' --private-ip-address "${MASTER2_IP}" \
--block-device-mapping "DeviceName=/dev/xvda,Ebs={DeleteOnTermination=true,VolumeSize=50,VolumeType=gp2,KmsKeyId=${KMS_KEY_ID},Encrypted=true}" \
--user-data "${MASTER2_UD}" | jq '.Instances[0].InstanceId' | tr -d '"')


# Notes on adding workers -----
# When the manifests were generated the worker count was set to 0 because the installer will not create them for us
# When you launch the instances below they will all spin around saying they don't know who they are
# This is because their CSRs have to be approved. After launching the instances start running 'oc get csr'
# and look for Pending CSRs to appear. You can approve them with 'oc adm certificate approve <first column of 'oc get csr'>


# AWS CLI to launch worker0
WORKER0_INSTANCE_ID=$(aws ${EC2_ENDPOINT} ${AWS_OPTS} ec2 run-instances --image-id "${AMI}" --count 1 --instance-type 'm5.2xlarge' \
--key-name 'Combine' --subnet-id "${EC2_SUBNET}" --security-group-ids "${K8S_WORKER_SG}" --ebs-optimized \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=caas-worker0}]' --private-ip-address "${WORKER0_IP}" \
--block-device-mapping "DeviceName=/dev/xvda,Ebs={DeleteOnTermination=true,VolumeSize=50,VolumeType=gp2,KmsKeyId=${KMS_KEY_ID},Encrypted=true}" \
--user-data "${WORKER0_UD}" | jq '.Instances[0].InstanceId' | tr -d '"')

# AWS CLI to launch worker1
WORKER1_INSTANCE_ID=$(aws ${EC2_ENDPOINT} ${AWS_OPTS} ec2 run-instances --image-id "${AMI}" --count 1 --instance-type 'm5.2xlarge' \
--key-name 'Combine' --subnet-id "${EC2_SUBNET}" --security-group-ids "${K8S_WORKER_SG}" --ebs-optimized \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=caas-worker1}]' --private-ip-address "${WORKER1_IP}" \
--block-device-mapping "DeviceName=/dev/xvda,Ebs={DeleteOnTermination=true,VolumeSize=50,VolumeType=gp2,KmsKeyId=${KMS_KEY_ID},Encrypted=true}" \
--user-data "${WORKER1_UD}" | jq '.Instances[0].InstanceId' | tr -d '"')

# AWS CLI to launch worker2
WORKER2_INSTANCE_ID=$(aws ${EC2_ENDPOINT} ${AWS_OPTS} ec2 run-instances --image-id "${AMI}" --count 1 --instance-type 'm5.2xlarge' \
--key-name 'Combine' --subnet-id "${EC2_SUBNET}" --security-group-ids "${K8S_WORKER_SG}" --ebs-optimized \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=caas-worker2}]' --private-ip-address "${WORKER2_IP}" \
--block-device-mapping "DeviceName=/dev/xvda,Ebs={DeleteOnTermination=true,VolumeSize=50,VolumeType=gp2,KmsKeyId=${KMS_KEY_ID},Encrypted=true}" \
--user-data "${WORKER2_UD}" | jq '.Instances[0].InstanceId' | tr -d '"')

aws ${ELB_ENDPOINT} ${AWS_OPTS} \
      elb register-instances-with-load-balancer --load-balancer-name "${OCP_CLUSTER_NAME}-ingress" --instances \
      "${MASTER0_INSTANCE_ID}" "${MASTER1_INSTANCE_ID}" "${MASTER2_INSTANCE_ID}" \
      "${WORKER0_INSTANCE_ID}" "${WORKER1_INSTANCE_ID}" "${WORKER2_INSTANCE_ID}"

exit 0
