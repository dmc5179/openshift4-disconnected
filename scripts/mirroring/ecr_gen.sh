#!/bin/bash

# Script to create repositories in ECR based on all of the operators in the redhat-operators manifests

REPO_LIST=()

for line in $(cat $1)
do

  if [[ $line =~ '@' ]]
  then
    REPO=$(echo "${line}" | awk -F\@ '{print $1}')
  else
    REPO=$(echo "${line}" | awk -F\: '{print $1}')
  fi

  REPO=$(echo "${REPO}" | sed 's/registry.redhat.io\///; s/quay.io\///; s/registry.access.redhat.com\///')

  #echo "${REPO}"

  REPO_LIST+=("${REPO}")

done

SORTED_UNIQUE_REPOS=($(echo "${REPO_LIST[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

set -x

aws ecr create-repository --repository-name "ocp4/openshift4" --image-tag-mutability MUTABLE

for repo in "${SORTED_UNIQUE_REPOS[@]}"
do

  aws ecr create-repository --repository-name "${repo}" --image-tag-mutability MUTABLE 

done

