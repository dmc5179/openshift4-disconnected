#!/bin/bash

DOCKER_ARCHIVE_DIR="/home/ec2-user/images/gpu-operator"

sudo skopeo copy docker-archive://${DOCKER_ARCHIVE_DIR}/gpu-operator-1.0.0.tar docker://<registry>:<port>/<repository>/gpu-operator:1.0.0

# Driver getting copied to 2 places because the helm chart isn't clear and there is no driver:440.33.01 tag in docker hub
sudo skopeo copy docker-archive://${DOCKER_ARCHIVE_DIR}/driver.440.33.01-rhcos4.3.tar docker://<registry>:<port>/<repository>/driver:440.33.01
sudo skopeo copy docker-archive://${DOCKER_ARCHIVE_DIR}/driver.440.33.01-rhcos4.3.tar docker://<registry>:<port>/<repository>/driver:440.33.01-rhcos4.3

sudo skopeo copy docker-archive://${DOCKER_ARCHIVE_DIR}/k8s-device-plugin.1.0.0-beta4.tar docker://<registry>:<port>/<repository>/k8s-device-plugin:1.0.0-beta4

sudo skopeo copy docker-archive://${DOCKER_ARCHIVE_DIR}/container-toolkit.1.0.0-alpha.3.tar docker://<registry>:<port>/<repository>/container-toolkit:1.0.0-alpha.3

sudo skopeo copy docker-archive://${DOCKER_ARCHIVE_DIR}/dcgm-exporter.1.0.0-beta-ubuntu18.04.tar docker://<registry>:<port>/<repository>/dcgm-exporter:1.0.0-beta-ubuntu18.04

sudo skopeo copy docker-archive://${DOCKER_ARCHIVE_DIR}/pod-gpu-metrics-exporter.v1.0.0-alpha.tar docker://<registry>:<port>/<repository>/pod-gpu-metrics-exporter:v1.0.0-alpha

