#!/bin/bash

# AWS CLI commands to launch instances
HTTPD_IP=""

# AWS CLI to launch bootstrap node
aws ec2 run-instances --image-id 'ami-00d4375c5625a0988' --count 1 --instance-type 'i3.large' \
--key-name 'Combine' --subnet-id 'subnet-092a00c216e3afdad' --security-group-ids 'sg-0b6c28f41aac7ce72' --ebs-optimized \
--tag-specifications 'ResourceType=string,Tags=[{Key=Name,Value=caas-bootstrap}]' --private-ip-address '<PRIVATE_IP>' \
--user-data '{"ignition":{"config":{"replace":{"source":"http://${HTTPD_IP}/openshift4/bootstrap.ign","verification":{}}},"timeouts":{},"version":"2.1.0"},"networkd":{},"passwd":{},"storage":{},"systemd":{}}'


# AWS CLI to launch master0
aws ec2 run-instances --image-id 'ami-00d4375c5625a0988' --count 1 --instance-type 'm5.2xlarge' \
--key-name 'Combine' --subnet-id 'subnet-092a00c216e3afdad' --security-group-ids 'sg-0b6c28f41aac7ce72' --ebs-optimized \
--tag-specifications 'ResourceType=string,Tags=[{Key=Name,Value=caas-master0}]' --private-ip-address '<PRIVATE_IP>' \
--user-data '{"ignition":{"config":{"replace":{"source":"http://${HTTPD_IP}/openshift4/master0.ign","verification":{}}},"timeouts":{},"version":"2.1.0"},"networkd":{},"passwd":{},"storage":{},"systemd":{}}'

# AWS CLI to launch master1
aws ec2 run-instances --image-id 'ami-00d4375c5625a0988' --count 1 --instance-type 'm5.2xlarge' \
--key-name 'Combine' --subnet-id 'subnet-092a00c216e3afdad' --security-group-ids 'sg-0b6c28f41aac7ce72' --ebs-optimized \
--tag-specifications 'ResourceType=string,Tags=[{Key=Name,Value=caas-master1}]' --private-ip-address '<PRIVATE_IP>' \
--user-data '{"ignition":{"config":{"replace":{"source":"http://${HTTPD_IP}/openshift4/master1.ign","verification":{}}},"timeouts":{},"version":"2.1.0"},"networkd":{},"passwd":{},"storage":{},"systemd":{}}'

# AWS CLI to launch master2
aws ec2 run-instances --image-id 'ami-00d4375c5625a0988' --count 1 --instance-type 'm5.2xlarge' \
--key-name 'Combine' --subnet-id 'subnet-092a00c216e3afdad' --security-group-ids 'sg-0b6c28f41aac7ce72' --ebs-optimized \
--tag-specifications 'ResourceType=string,Tags=[{Key=Name,Value=caas-master2}]' --private-ip-address '<PRIVATE_IP>' \
--user-data '{"ignition":{"config":{"replace":{"source":"http://${HTTPD_IP}/openshift4/master2.ign","verification":{}}},"timeouts":{},"version":"2.1.0"},"networkd":{},"passwd":{},"storage":{},"systemd":{}}'


# Notes on adding workers -----
# When the manifests were generated the worker count was set to 0 because the installer will not create them for us
# When you launch the instances below they will all spin around saying they don't know who they are
# This is because their CSRs have to be approved. After launching the instances start running 'oc get csr'
# and look for Pending CSRs to appear. You can approve them with 'oc adm certificate approve <first column of 'oc get csr'>


# AWS CLI to launch worker0
aws ec2 run-instances --image-id 'ami-00d4375c5625a0988' --count 1 --instance-type 'm5.2xlarge' \
--key-name 'Combine' --subnet-id 'subnet-092a00c216e3afdad' --security-group-ids 'sg-0b6c28f41aac7ce72' --ebs-optimized \
--tag-specifications 'ResourceType=string,Tags=[{Key=Name,Value=caas-worker0}]' --private-ip-address '<PRIVATE_IP>' \
--user-data '{"ignition":{"config":{"replace":{"source":"http://${HTTPD_IP}/openshift4/worker0.ign","verification":{}}},"timeouts":{},"version":"2.1.0"},"networkd":{},"passwd":{},"storage":{},"systemd":{}}'

# AWS CLI to launch worker1
aws ec2 run-instances --image-id 'ami-00d4375c5625a0988' --count 1 --instance-type 'm5.2xlarge' \
--key-name 'Combine' --subnet-id 'subnet-092a00c216e3afdad' --security-group-ids 'sg-0b6c28f41aac7ce72' --ebs-optimized \
--tag-specifications 'ResourceType=string,Tags=[{Key=Name,Value=caas-worker1}]' --private-ip-address '<PRIVATE_IP>' \
--user-data '{"ignition":{"config":{"replace":{"source":"http://${HTTPD_IP}/openshift4/worker1.ign","verification":{}}},"timeouts":{},"version":"2.1.0"},"networkd":{},"passwd":{},"storage":{},"systemd":{}}'

# AWS CLI to launch worker2
aws ec2 run-instances --image-id 'ami-00d4375c5625a0988' --count 1 --instance-type 'm5.2xlarge' \
--key-name 'Combine' --subnet-id 'subnet-092a00c216e3afdad' --security-group-ids 'sg-0b6c28f41aac7ce72' --ebs-optimized \
--tag-specifications 'ResourceType=string,Tags=[{Key=Name,Value=caas-worker2}]' --private-ip-address '<PRIVATE_IP>' \
--user-data '{"ignition":{"config":{"replace":{"source":"http://${HTTPD_IP}/openshift4/worker2.ign","verification":{}}},"timeouts":{},"version":"2.1.0"},"networkd":{},"passwd":{},"storage":{},"systemd":{}}'



