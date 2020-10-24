#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Source the environment file with the default settings
source "${SCRIPT_DIR}/../env.sh"

INSTANCE_IDS=""

for host in bootstrap master0 master1 master2 worker0 worker1 worker2
do

  ID=$(aws ${EC2_ENDPOINT} ${AWS_OPTS} ec2 describe-instances \
      --filters "Name=tag:Name,Values=caas-${host}" "Name=instance-state-name,Values=stopped" \
      --query "Reservations[*].Instances[*].InstanceId" \
      --output text)

   if [[ ! -z "${ID}" ]]
   then
     echo "Adding: $ID"
     INSTANCE_IDS="${INSTANCE_IDS} $ID"
   fi

done

aws ${EC2_ENDPOINT} ${AWS_OPTS} ec2 start-instances --instance-ids ${INSTANCE_IDS}
