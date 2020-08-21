#!/bin/bash -xe

# Create Ignition files for each node based on the base ignition file and the fake root for each host

# WARNING !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# If you create ignition configs today and install the cluster tomorrow your 24 hour
# initial certs might be expired so you really have to regenerate the ignition files on
# every install attempt. The certs are generated when you create the ignition files. 
# Not when you start to install the cluster
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

set -x

# Source env file
. env.sh

export KUBECONFIG="${IGNITION_CONFIGS}/auth/kubeconfig"

rm -rf "${IGNITION_CONFIGS}"
mkdir "${IGNITION_CONFIGS}"

cp "${INSTALL_CONFIG}" "${IGNITION_CONFIGS}/"

${OPENSHIFT_INSTALL} create manifests --dir=${IGNITION_CONFIGS}

# In a UPI install the workers are set to 0. The installer is not going to make worker nodes for us
# Because of this we need to make the masters as not schedulable. If we do not do this then the cluster
# will try to start scheduling things on the master nodes which we don't want
sed -i 's/mastersSchedulable: true/mastersSchedulable: false/g' ${IGNITION_CONFIGS}/manifests/cluster-scheduler-02-config.yml

# Set the cluster version operator to use a dummy value
sed -i 's/channel:.*/channel: fast/' ${IGNITION_CONFIGS}/manifests/cvo-overrides.yaml
sed -i 's|upstream:.*|upstream: http://localhost:8080/graph|' ${IGNITION_CONFIGS}/manifests/cvo-overrides.yaml

${OPENSHIFT_INSTALL} create ignition-configs --dir=${IGNITION_CONFIGS}

# Customize bootstrap ignition
python3 "${FILETRANSPILE}" -i "${IGNITION_CONFIGS}/bootstrap.ign" -f "${FAKEROOTS}/bootstrap_fake-root"  --format json > "${IGNITION_CONFIGS}/bootstrap_static.ign"
mv "${IGNITION_CONFIGS}/bootstrap_static.ign" "${IGNITION_CONFIGS}/bootstrap.ign"

# Customize master node ignition files. Need 1 for each due to static IPs
for i in $(seq 0 $(expr ${MASTERS} - 1))
do

  python3 "${FILETRANSPILE}" -i "${IGNITION_CONFIGS}/master.ign" -f "${FAKEROOTS}/master${i}_fake-root" --format json > "${IGNITION_CONFIGS}/master${i}.ign"

done

# Customize worker node ignition files. Need 1 for each due to static IPs
for i in $(seq 0 $(expr ${WORKERS} - 1))
do

  python3 "${FILETRANSPILE}" -i "${IGNITION_CONFIGS}/worker.ign" -f "${FAKEROOTS}/worker${i}_fake-root" --format json > "${IGNITION_CONFIGS}/worker${i}.ign"

done

exit 0
