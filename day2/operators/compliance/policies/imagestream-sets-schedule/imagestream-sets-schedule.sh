#!/bin/bash

#NAME    IMAGE REPOSITORY                 TAGS                                 UPDATED


while IFS= read -r line; do
  #echo "Processing line: $line"
  NAMESPACE=$(echo "$line" | awk '{print $1}')
  NAME=$(echo "$line" | awk '{print $2}')
  TAGS=$(echo "$line" | awk '{print $4}')

  #echo "Tags: ${TAGS}"

  IFS=',' read -ra TAG <<< "$TAGS"
  for tag_name in "${TAG[@]}"; do
    #echo "tag: ${tag_name}"
    oc patch imagestream ${NAME} -n ${NAMESPACE} --type merge -p '{"spec":{"tags":[{"name":"${tag_name}","importPolicy":{"scheduled":true}}]}}'
    sleep 0.01
  done

done <<<$(oc get --no-headers=true -A is)
