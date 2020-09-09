#!/bin/bash

SC="localblock-sc"

oc patch storageclass "${SC}" -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
