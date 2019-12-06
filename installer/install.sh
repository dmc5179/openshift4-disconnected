#!/bin/bash

INSTALL_DIR=/home/ec2-user/openshift4
INSTALL_BUCKET='redhat-combine'

openshift-install create manifests --dir=${INSTALL_DIR}

sed -i 's/mastersSchedulable: true/mastersSchedulable: False/' manifests/cluster-scheduler-02-config.yml

openshift-install create ignition-configs --dir=${INSTALL_DIR}


aws s3 cp bootstrap.ign "s3://${INSTALL_BUCKET}/"
aws s3 cp master.ign "s3://${INSTALL_BUCKET}/"
aws s3 cp metadata.ign "s3://${INSTALL_BUCKET}/"
aws s3 cp metadata.json "s3://${INSTALL_BUCKET}/"
aws s3 cp worker.ign "s3://${INSTALL_BUCKET}/"

