#!/bin/bash

aws cloudformation create-stack --stack-name <name>
     --template-body file://<template>.yaml
     --parameters file://<parameters>.json
     --capabilities CAPABILITY_NAMED_IAM
