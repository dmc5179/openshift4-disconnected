#!/bin/bash

# $1 = device name; i.e eth0
# $2 = IP; 192.168.1.100
# $3 = NETMASK; 255.255.255.0
# $4 = GATEWAY; 192.168.1.1
# $5 = Base ignition file; master.ign
# $6 = Output ignition file; master0.ign


MY_DEVICE_NAME="$1"
MY_IPADDR=$2
MY_NETMASK=$3
MY_GATEWAY=$4
MY_INPUT_IGN=$5
MY_OUTPUT_IGN=$6

if test -z $MY_DEVICE_NAME || test -z $MY_IPADDR || test -z $MY_NETMASK || test -z $MY_GATEWAY || test -z $MY_INPUT_IGN || test -z $MY_OUTPUT_IGN
then
  echo "Need all 6 options set"
  exit 1
fi

cat << EOF > /tmp/network.conf
TYPE=Ethernet
BOOTPROTO=none
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=no
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
NAME="${MY_DEVICE_NAME}"
DEVICE=${MY_DEVICE_NAME}
ONBOOT=yes
IPADDR=${MY_IPADDR}
NETMASK=${MY_NETMASK}
GATEWAY=${MY_GATEWAY}
EOF

NET_BASE64=$(cat /tmp/network.conf | base64 -w 0)

cat << EOF > /tmp/network.json
{
  "path": "/etc/sysconfig/network-scripts/ifcfg-${MY_DEVICE_NAME}",
  "mode": 420,
  "overwrite": true,
  "contents": {
    "source": "data:text/plain;charset=us-ascii;base64,${NET_BASE64}"
  }
}
EOF

jq --slurpfile obj /tmp/network.json '.storage.files += [$obj]' "${MY_INPUT_IGN}" > "${MY_OUTPUT_IGN}"

