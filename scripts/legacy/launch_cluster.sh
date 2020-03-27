#!/bin/bash

AMI="ami-"
WEBSERVER="http://1.2.3.4/openshift4"
SUBNET="subnet-"
SEC_GROUPS="sg-"

# AWS CLI to launch bootstrap node
${AWS_EC2} ec2 run-instances --image-id "${AMI}" --count 1 --instance-type 'i3.large' \
--key-name 'Combine' --subnet-id "${SUBNET}" --security-group-ids "${SEC_GROUPS}" --ebs-optimized \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=caas-bootstrap}]' --private-ip-address '10.0.106.50' \
--user-data '{"ignition":{"config":{"replace":{"source":"${WEBSERVER}/bootstrap.ign","verification":{}}},"timeouts":{},"version":"2.1.0"},"networkd":{},"passwd":{},"storage":{},"systemd":{}}'

# AWS CLI to launch master0
${AWS_EC2} ec2 run-instances --image-id "${AMI}" --count 1 --instance-type 'm4.xlarge' \
--key-name 'Combine' --subnet-id "${SUBNET}" --security-group-ids "${SEC_GROUPS}" --ebs-optimized \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=caas-master0}]' --private-ip-address '10.0.106.51' \
--user-data '{"ignition":{"config":{"replace":{"source":"${WEBSERVER}/master0.ign","verification":{}}},"timeouts":{},"version":"2.1.0"},"networkd":{},"passwd":{},"storage":{},"systemd":{}}'

# AWS CLI to launch master1
${AWS_EC2} ec2 run-instances --image-id "${AMI}" --count 1 --instance-type 'm4.xlarge' \
--key-name 'Combine' --subnet-id "${SUBNET}" --security-group-ids "${SEC_GROUPS}" --ebs-optimized \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=caas-master1}]' --private-ip-address '10.0.106.52' \
--user-data '{"ignition":{"config":{"replace":{"source":"${WEBSERVER}/master1.ign","verification":{}}},"timeouts":{},"version":"2.1.0"},"networkd":{},"passwd":{},"storage":{},"systemd":{}}'

# AWS CLI to launch master2
${AWS_EC2} ec2 run-instances --image-id "${AMI}" --count 1 --instance-type 'm4.xlarge' \
--key-name 'Combine' --subnet-id "${SUBNET}" --security-group-ids "${SEC_GROUPS}" --ebs-optimized \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=caas-master2}]' --private-ip-address '10.0.106.53' \
--user-data '{"ignition":{"config":{"replace":{"source":"${WEBSERVER}/master2.ign","verification":{}}},"timeouts":{},"version":"2.1.0"},"networkd":{},"passwd":{},"storage":{},"systemd":{}}'

# AWS CLI to launch worker0
${AWS_EC2} ec2 run-instances --image-id "${AMI}" --count 1 --instance-type 'm4.xlarge' \
--key-name 'Combine' --subnet-id "${SUBNET}" --security-group-ids "${SEC_GROUPS}" --ebs-optimized \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=caas-worker0}]' --private-ip-address '10.0.106.61' \
--user-data '{"ignition":{"config":{"replace":{"source":"${WEBSERVER}/worker0.ign","verification":{}}},"timeouts":{},"version":"2.1.0"},"networkd":{},"passwd":{},"storage":{},"systemd":{}}'

# AWS CLI to launch worker1
${AWS_EC2} ec2 run-instances --image-id "${AMI}" --count 1 --instance-type 'm4.xlarge' \
--key-name 'Combine' --subnet-id "${SUBNET}" --security-group-ids "${SEC_GROUPS}" --ebs-optimized \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=caas-worker1}]' --private-ip-address '10.0.106.62' \
--user-data '{"ignition":{"config":{"replace":{"source":"${WEBSERVER}/worker1.ign","verification":{}}},"timeouts":{},"version":"2.1.0"},"networkd":{},"passwd":{},"storage":{},"systemd":{}}'

# AWS CLI to launch worker2
${AWS_EC2} ec2 run-instances --image-id "${AMI}" --count 1 --instance-type 'm4.xlarge' \
--key-name 'Combine' --subnet-id "${SUBNET}" --security-group-ids "${SEC_GROUPS}" --ebs-optimized \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=caas-worker2}]' --private-ip-address '10.0.106.63' \
--user-data '{"ignition":{"config":{"replace":{"source":"${WEBSERVER}/worker2.ign","verification":{}}},"timeouts":{},"version":"2.1.0"},"networkd":{},"passwd":{},"storage":{},"systemd":{}}'


