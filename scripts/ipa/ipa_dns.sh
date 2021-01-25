#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Source the environment file with the default settings
source "${SCRIPT_DIR}/../env.sh"

# Command to install an IPA Server
#ipa-server-install -p 'COMPLEX_PASSWORD' -a 'COMPLEX_PASSWORD' --setup-dns \
#    --hostname=ipa-master.${OCP_CLUSTER_NAME}.${OCP_DOMAIN} --ip-address=10.0.106.35 \
#    --no-forwarder --auto-reverse --no-dnssec-validation --domain=${OCP_DOMAIN} \
#    --realm=${OCP_DOMAIN_UPPER}
#ipa dnsrecord-add "${BASE_DOMAIN}" ipa-master.${OCP_CLUSTER_NAME} --a-rec

set -x

CLUSTER_ZONE="${OCP_CLUSTER_NAME}.${OCP_BASE_DOMAIN}"

ipa dnszone-add "${CLUSTER_ZONE}"

# pointers to load api load balancer
ipa dnsrecord-add "${CLUSTER_ZONE}" api --a-rec "${API_LB_IP}"
ipa dnsrecord-add "${CLUSTER_ZONE}" api-int --a-rec "${API_INT_LB_IP}"

# The wildcard also points to the load balancer
ipa dnsrecord-add "${CLUSTER_ZONE}" *.apps --a-rec "${APPS_LB_IP}"

# Create entry for the bootstrap host
ipa dnsrecord-add "${CLUSTER_ZONE}" bootstrap --a-rec "${BOOTSTRAP_IP}"

# Create entries for the master hosts
ipa dnsrecord-add "${CLUSTER_ZONE}" master0 --a-rec "${MASTER0_IP}"
ipa dnsrecord-add "${CLUSTER_ZONE}" master1 --a-rec "${MASTER1_IP}"
ipa dnsrecord-add "${CLUSTER_ZONE}" master2 --a-rec "${MASTER2_IP}"

# Create entries for the worker hosts
ipa dnsrecord-add "${CLUSTER_ZONE}" worker0 --a-rec "${WORKER0_IP}"
ipa dnsrecord-add "${CLUSTER_ZONE}" worker1 --a-rec "${WORKER1_IP}"
ipa dnsrecord-add "${CLUSTER_ZONE}" worker2 --a-rec "${WORKER2_IP}"

# The ETCd cluster lives on the masters...so point these to the IP of the masters
ipa dnsrecord-add "${CLUSTER_ZONE}" etcd-0 --a-rec "${MASTER0_IP}"
ipa dnsrecord-add "${CLUSTER_ZONE}" etcd-1 --a-rec "${MASTER1_IP}"
ipa dnsrecord-add "${CLUSTER_ZONE}" etcd-2 --a-rec "${MASTER2_IP}"

# The SRV records ...note the trailing dot at the end.
# Not required since OpenShift 4.3
#ipa dnsrecord-add ${CLUSTER_ZONE} --srv-rec=_etcd-server-ssl._tcp.${OCP_CLUSTER_NAME} --srv-priority=0 --srv-weight=10 --srv-port=2380 --srv-target=etcd-0.${OCP_CLUSTER_NAME}.${OCP_BASE_DOMAIN}.
#ipa dnsrecord-add ${CLUSTER_ZONE} --srv-rec=_etcd-server-ssl._tcp.${OCP_CLUSTER_NAME} --srv-priority=0 --srv-weight=10 --srv-port=2380 --srv-target=etcd-1.${OCP_CLUSTER_NAME}.${OCP_BASE_DOMAIN}.
#ipa dnsrecord-add ${CLUSTER_ZONE} --srv-rec=_etcd-server-ssl._tcp.${OCP_CLUSTER_NAME} --srv-priority=0 --srv-weight=10 --srv-port=2380 --srv-target=etcd-2.${OCP_CLUSTER_NAME}.${OCP_BASE_DOMAIN}.
#
#ipa dnsrecord-add "${CLUSTER_ZONE}" _etcd-server-ssl._tcp.${OCP_CLUSTER_NAME} --srv-rec="0 10 2380 etcd-0.${OCP_CLUSTER_NAME}.${OCP_BASE_DOMAIN}."
#ipa dnsrecord-add "${CLUSTER_ZONE}" _etcd-server-ssl._tcp.${OCP_CLUSTER_NAME} --srv-rec="0 10 2380 etcd-1.${OCP_CLUSTER_NAME}.${OCP_BASE_DOMAIN}."
#ipa dnsrecord-add "${CLUSTER_ZONE}" _etcd-server-ssl._tcp.${OCP_CLUSTER_NAME} --srv-rec="0 10 2380 etcd-2.${OCP_CLUSTER_NAME}.${OCP_BASE_DOMAIN}."

ipa dnsrecord-add $(echo "${MASTER0_IP}" | awk -F. -vOFS=. '{print $3,$2,$1,"in-addr.arpa."}') \
                  $(echo $MASTER0_IP | awk -F\. '{print $NF}') --ptr-rec=master0.${CLUSTER_ZONE}.

ipa dnsrecord-add $(echo "${MASTER1_IP}" | awk -F. -vOFS=. '{print $3,$2,$1,"in-addr.arpa."}') \
                  $(echo $MASTER1_IP | awk -F\. '{print $NF}') --ptr-rec=master1.${CLUSTER_ZONE}.

ipa dnsrecord-add $(echo "${MASTER2_IP}" | awk -F. -vOFS=. '{print $3,$2,$1,"in-addr.arpa."}') \
                  $(echo $MASTER2_IP | awk -F\. '{print $NF}') --ptr-rec=master2.${CLUSTER_ZONE}.

ipa dnsrecord-add $(echo "${WORKER0_IP}" | awk -F. -vOFS=. '{print $3,$2,$1,"in-addr.arpa."}') \
                  $(echo $WORKER0_IP | awk -F\. '{print $NF}') --ptr-rec=worker0.${CLUSTER_ZONE}.

ipa dnsrecord-add $(echo "${WORKER1_IP}" | awk -F. -vOFS=. '{print $3,$2,$1,"in-addr.arpa."}') \
                  $(echo $WORKER1_IP | awk -F\. '{print $NF}') --ptr-rec=worker1.${CLUSTER_ZONE}.

ipa dnsrecord-add $(echo "${WORKER2_IP}" | awk -F. -vOFS=. '{print $3,$2,$1,"in-addr.arpa."}') \
                  $(echo $WORKER2_IP | awk -F\. '{print $NF}') --ptr-rec=worker2.${CLUSTER_ZONE}.

ipa dnsrecord-add $(echo "${BOOTSTRAP_IP}" | awk -F. -vOFS=. '{print $3,$2,$1,"in-addr.arpa."}') \
                  $(echo $BOOTSTRAP_IP | awk -F\. '{print $NF}') --ptr-rec=bootstrap.${CLUSTER_ZONE}.

exit 0
# Example ipa commands
#ipa dnsrecord-del 106.0.10.in-addr.arpa. --ptr-rec=master0 ${OCP_CLUSTER_NAME}.${OCP_BASE_DOMAIN}.
