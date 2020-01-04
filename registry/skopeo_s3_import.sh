#!/bin/bash

# This script will pull down images from an S3 bucket and use skopeo to push
# them to another registry

BUCKET=ocp-4.2.0
REGISTRY=registry-ocp4.redhat.com:5000

#podman login -u dummy -p dummy ${REGISTRY}

cd

aws s3 cp 's3://ocp-4.2.0/images/images.txt' .

for i in $(cat images.txt)
do
	PATH_NAME=$(echo $i | awk -F\: '{print $1}')
	NAME=$(echo ${PATH_NAME} | awk -F\/ '{print $2}')
	VERSION=$(echo $i | awk -F\: '{print $2}')
	mkdir "${NAME}" || true
	aws s3 cp --recursive "s3://${BUCKET}/images/${NAME}/" "${NAME}"
	sudo skopeo copy "dir:${NAME}"  "docker://${REGISTRY}/${PATH_NAME}:${VERSION}"
	rm -rf "${NAME}"
done

# 
#skopeo copy --dest-tls-verify=false containers-storage:tripleomaster/centos-binary-heat-api:current-tripleo docker://localhost:5000/tripleomaster/centos-binary-heat-api:current-tripleo

