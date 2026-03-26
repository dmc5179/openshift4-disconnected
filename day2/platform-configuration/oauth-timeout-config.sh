#!/bin/bash

oc patch oauth cluster --type='merge' -p '{"spec": {"tokenConfig": {"accessTokenMaxAgeSeconds": 28800}}}'
