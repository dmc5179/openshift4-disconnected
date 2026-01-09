#!/bin/bash -xe

date +"%Y-%m-%dT%H:%M:%S%:z"



oc adm ocp-certificates regenerate-leaf -n openshift-config-managed secrets kube-controller-manager-client-cert-key kube-scheduler-client-cert-key

oc adm ocp-certificates regenerate-leaf -n openshift-kube-apiserver-operator secrets node-system-admin-client

oc adm ocp-certificates regenerate-leaf -n openshift-kube-apiserver secrets check-endpoints-client-cert-key control-plane-node-admin-client-cert-key  external-loadbalancer-serving-certkey internal-loadbalancer-serving-certkey kubelet-client localhost-recovery-serving-certkey localhost-serving-cert-certkey service-network-serving-certkey

oc adm wait-for-stable-cluster # Took almost 10 minutes

oc adm ocp-certificates regenerate-top-level -n openshift-kube-apiserver-operator secrets kube-apiserver-to-kubelet-signer kube-control-plane-signer loadbalancer-serving-signer  localhost-serving-signer service-network-serving-signer

oc -n openshift-kube-controller-manager-operator delete secrets/next-service-account-private-key

oc -n openshift-kube-apiserver-operator delete secrets/next-bound-service-account-signing-key

# Wait maybe 10-15 seconds before running this command
sleep 15
oc adm wait-for-stable-cluster # Took

oc adm ocp-certificates regenerate-leaf -n openshift-config-managed secrets kube-controller-manager-client-cert-key kube-scheduler-client-cert-key

oc config refresh-ca-bundle

oc config new-kubelet-bootstrap-kubeconfig > bootstrap.kubeconfig

oc whoami --kubeconfig=bootstrap.kubeconfig --server=$(oc get infrastructure/cluster -ojsonpath='{ .status.apiServerURL }')

oc adm copy-to-node nodes --all --copy=bootstrap.kubeconfig=/etc/kubernetes/kubeconfig

oc adm restart-kubelet nodes --all --directive=RemoveKubeletKubeconfig

oc adm reboot-machine-config-pool mcp/worker mcp/master

oc adm wait-for-node-reboot nodes --all

oc adm ocp-certificates regenerate-leaf -n openshift-kube-apiserver-operator secrets node-system-admin-client

oc adm ocp-certificates regenerate-leaf -n openshift-kube-apiserver secrets check-endpoints-client-cert-key control-plane-node-admin-client-cert-key external-loadbalancer-serving-certkey internal-loadbalancer-serving-certkey kubelet-client localhost-recovery-serving-certkey localhost-serving-cert-certkey service-network-serving-certkey

sleep  15
oc adm wait-for-stable-cluster # Took

oc config new-admin-kubeconfig > admin.kubeconfig

oc --kubeconfig=admin.kubeconfig whoami

oc adm ocp-certificates remove-old-trust -n openshift-kube-apiserver-operator configmaps kube-apiserver-to-kubelet-client-ca kube-control-plane-signer-ca loadbalancer-serving-ca localhost-serving-ca service-network-serving-ca --created-before=<date-from-step-1>

sleep 15
oc adm wait-for-stable-cluster # Took

oc adm reboot-machine-config-pool mcp/worker mcp/master

oc adm wait-for-node-reboot nodes --all


###########################################

oc get secret/machine-config-server-tls -n openshift-machine-config-operator -oyaml > machine-config-server-tls.bak
oc get secret/machine-config-server-ca -n openshift-machine-config-operator -oyaml > machine-config-server-ca.bak

oc adm ocp-certificates regenerate-machine-config-server-serving-cert

oc adm ocp-certificates regenerate-machine-config-server-serving-cert
oc adm ocp-certificates update-ignition-ca-bundle-for-machine-config-server

oc adm ocp-certificates regenerate-machine-config-server-serving-cert --update-ignition=false
oc -n openshift-machine-config-operator get secrets


