#!/bin/bahs

# Method 1, get from kubeconfig
#

# There are 2 CA bundles in the kubeconfig
yq '.clusters[0].cluster.certificate-authority-data' /home/danclark/workspace/nga_ecs/cluster/auth/kubeconfig | base64 -d > ecs.crt
yq '.clusters[1].cluster.certificate-authority-data' /home/danclark/workspace/nga_ecs/cluster/auth/kubeconfig | base64 -d > api.crt

# Method 2, get from OpenShift itself
#

oc get configmap default-ingress-cert -n openshift-config-managed -o jsonpath='{.data.ca-bundle\.crt}' > openshift-cluster-ca.crt
