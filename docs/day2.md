# OpenShift 4 Day 2 Operations

**Table of Contents**
  - [Purpose](#Purpose)


### Purpose

This doc contains steps to perform simple actions in OpenShift 4

#### Disable Master Scheduling
```
oc patch --type=merge --patch='{"spec":{"mastersSchedulable": false}}' schedulers.config.openshift.io cluster
```
