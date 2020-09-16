#!/bin/bash

if [ $# -eq 0 ]
  then
    echo "No arguments supplied: Pass in the name of the storage class and true/false to set the default value"
    echo "Usage: $0 <storage class name> <true/false>"
fi

SC="$1"
DEFAULT="$2"

oc patch storageclass "${SC}" -p "{\"metadata\": {\"annotations\":{\"storageclass.kubernetes.io/is-default-class\":\"${DEFAULT}\"}}}"
