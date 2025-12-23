#!/bin/bash

oc patch HelmChartRepository openshift-helm-charts --type json -p '[{"op": "add", "path": "/spec/disabled", "value": true}]'
