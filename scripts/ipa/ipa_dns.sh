#!/bin/bash

OCP_DOMAIN='redhatgovsa.io'
OCP_CLUSTER_NAME='caas'

# Command to install an IPA Server
ipa-server-install -p 'COMPLEX_PASSWORD' -a 'COMPLEX_PASSWORD' --setup-dns --hostname=ipa-master.${OCP_CLUSTER_NAME}.${OCP_DOMAIN} --ip-address=10.0.106.35 --no-forwarder --auto-reverse --no-dnssec-validation --domain=${OCP_DOMAIN} --realm=${OCP_DOMAIN_UPPER}


ipa dnsrecord-add "${BASE_DOMAIN}" ipa-master.${OCP_CLUSTER_NAME} --a-rec 10.0.106.35

# pointers to load api load balancer
ipa dnsrecord-add "${BASE_DOMAIN}" api.${OCP_CLUSTER_NAME} --a-rec 10.0.106.41
ipa dnsrecord-add "${BASE_DOMAIN}" api-int.${OCP_CLUSTER_NAME} --a-rec 10.0.106.41

# The wildcard also points to the load balancer
ipa dnsrecord-add "${BASE_DOMAIN}" *.apps.${OCP_CLUSTER_NAME} --a-rec 10.0.106.42

# Create entry for the bootstrap host
ipa dnsrecord-add "${BASE_DOMAIN}" bootstrap.${OCP_CLUSTER_NAME} --a-rec 10.0.106.50

# Create entries for the master hosts
ipa dnsrecord-add "${BASE_DOMAIN}" master0.${OCP_CLUSTER_NAME} --a-rec 10.0.106.51
ipa dnsrecord-add "${BASE_DOMAIN}" master1.${OCP_CLUSTER_NAME} --a-rec 10.0.106.52
ipa dnsrecord-add "${BASE_DOMAIN}" master2.${OCP_CLUSTER_NAME} --a-rec 10.0.106.53

# Create entries for the worker hosts
ipa dnsrecord-add "${BASE_DOMAIN}" worker0.${OCP_CLUSTER_NAME} --a-rec 10.0.106.61
ipa dnsrecord-add "${BASE_DOMAIN}" worker1.${OCP_CLUSTER_NAME} --a-rec 10.0.106.62
ipa dnsrecord-add "${BASE_DOMAIN}" worker2.${OCP_CLUSTER_NAME} --a-rec 10.0.106.63

# The ETCd cluster lives on the masters...so point these to the IP of the masters
ipa dnsrecord-add "${BASE_DOMAIN}" etcd-0.${OCP_CLUSTER_NAME} --a-rec 10.0.106.51
ipa dnsrecord-add "${BASE_DOMAIN}" etcd-1.${OCP_CLUSTER_NAME} --a-rec 10.0.106.52
ipa dnsrecord-add "${BASE_DOMAIN}" etcd-2.${OCP_CLUSTER_NAME} --a-rec 10.0.106.53

# The SRV records ...note the trailing dot at the end.
ipa dnsrecord-add ${BASE_DOMAIN} --srv-rec=_etcd-server-ssl._tcp.${OCP_CLUSTER_NAME} --srv-priority=0 --srv-weight=10 --srv-port=2380 --srv-target=etcd-0.${OCP_CLUSTER_NAME}.redhatgovsa.io.
ipa dnsrecord-add ${BASE_DOMAIN} --srv-rec=_etcd-server-ssl._tcp.${OCP_CLUSTER_NAME} --srv-priority=0 --srv-weight=10 --srv-port=2380 --srv-target=etcd-1.${OCP_CLUSTER_NAME}.redhatgovsa.io.
ipa dnsrecord-add ${BASE_DOMAIN} --srv-rec=_etcd-server-ssl._tcp.${OCP_CLUSTER_NAME} --srv-priority=0 --srv-weight=10 --srv-port=2380 --srv-target=etcd-2.${OCP_CLUSTER_NAME}.redhatgovsa.io.

ipa dnsrecord-add "${BASE_DOMAIN}" _etcd-server-ssl._tcp.${OCP_CLUSTER_NAME} --srv-rec="0 10 2380 etcd-0.${OCP_CLUSTER_NAME}.redhatgovsa.io."
ipa dnsrecord-add "${BASE_DOMAIN}" _etcd-server-ssl._tcp.${OCP_CLUSTER_NAME} --srv-rec="0 10 2380 etcd-1.${OCP_CLUSTER_NAME}.redhatgovsa.io."
ipa dnsrecord-add "${BASE_DOMAIN}" _etcd-server-ssl._tcp.${OCP_CLUSTER_NAME} --srv-rec="0 10 2380 etcd-2.${OCP_CLUSTER_NAME}.redhatgovsa.io."

#ipa dnsrecord-del 106.0.10.in-addr.arpa. --ptr-rec=master0 ${OCP_CLUSTER_NAME}.redhatgovsa.io.
ipa dnsrecord-add 106.0.10.in-addr.arpa. 51 --ptr-rec=master0.${OCP_CLUSTER_NAME}.redhatgovsa.io.
ipa dnsrecord-add 106.0.10.in-addr.arpa. 52 --ptr-rec=master1.${OCP_CLUSTER_NAME}.redhatgovsa.io.
ipa dnsrecord-add 106.0.10.in-addr.arpa. 53 --ptr-rec=master2.${OCP_CLUSTER_NAME}.redhatgovsa.io.
ipa dnsrecord-add 106.0.10.in-addr.arpa. 61 --ptr-rec=worker0.${OCP_CLUSTER_NAME}.redhatgovsa.io.
ipa dnsrecord-add 106.0.10.in-addr.arpa. 62 --ptr-rec=worker1.${OCP_CLUSTER_NAME}.redhatgovsa.io.
ipa dnsrecord-add 106.0.10.in-addr.arpa. 63 --ptr-rec=worker2.${OCP_CLUSTER_NAME}.redhatgovsa.io.
ipa dnsrecord-add 106.0.10.in-addr.arpa. 50 --ptr-rec=bootstrap.${OCP_CLUSTER_NAME}.redhatgovsa.io.
