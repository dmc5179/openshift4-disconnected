#!/bin/bash -xe

# Script to stage the ignition files on an http server

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  
# Source the environment file with the default settings
source "${SCRIPT_DIR}/../env.sh"

# Copy the ignition files to their destination location
sudo rm -rf /var/www/html/ignition/
sudo mkdir -p /var/www/html/ignition/
sudo cp -aR ${IGNITION_CONFIGS}/*.ign /var/www/html/ignition/
sudo chown -R root.root /var/www/html/ignition
sudo chmod -R 755 "/var/www/html/ignition"
sudo restorecon -vR /var/www/html/ignition


