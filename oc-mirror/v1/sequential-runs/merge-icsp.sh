#!/bin/bash

# Incomplete. Need to merge the files together or just not have them all named operator-0

for icsp in $(find oc-mirror-workspace/results-17570* -name imageContentSourcePolicy.yaml)
do

  yq '. | select(.metadata.name == "operator-0")' "${icsp}"

done 
