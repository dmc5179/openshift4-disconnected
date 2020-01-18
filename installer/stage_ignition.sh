#!/bin/bash

# Script to stage the ignition files on an http server


# Copy the ignition files to their destination location
sudo rm -rf /var/www/html/openshift4/
sudo cp -aR "${IGNITION_CONFIGS}" /var/www/html/
sudo chown -R root.root /var/www/html/openshift4
sudo chmod -R 755 "/var/www/html/$(basename ${IGNITION_CONFIGS})"
sudo restorecon -vR /var/www/html/openshift4


