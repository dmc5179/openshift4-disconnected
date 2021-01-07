#!/bin/bash

BOOTSTRAP=(10.15.169.11)
MASTERS=(10.15.169.12 10.15.169.13 10.15.169.14)
WORKERS=(10.15.169.15 10.15.169.16)
HOSTS=()

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
bmc_user=""
bmc_password=""
bootstrap="false"
masters="false"
workers="false"

while getopts "h?u:p:bmw" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    u)  bmc_user=$OPTARG
        ;;
    p)  bmc_password=$OPTARG
        ;;
    b)  HOSTS=("${HOSTS[@]}" "${BOOTSTRAP[@]}")
        ;;
    m)  HOSTS=("${HOSTS[@]}" "${MASTERS[@]}")
        ;;
    w)  HOSTS=("${HOSTS[@]}" "${WORKERS[@]}")
        ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

echo "Working on: ${HOSTS[@]}"

if test -z "$bmc_user"
then
  echo "User required"
  exit 1
fi

if test -z "$bmc_password"
then
  echo "Password required"
  exit 1
fi

set -xe

for host in ${HOSTS[@]}
do
  /opt/dell/srvadmin/sbin/racadm -u "$bmc_user" -p "$bmc_password" -r "$host" serveraction powerdown

  sleep 2

  /opt/dell/srvadmin/sbin/racadm -u "$bmc_user" -p "$bmc_password" -r "$host" config -g cfgServerInfo -o cfgServerBootOnce 1

  sleep 2

  /opt/dell/srvadmin/sbin/racadm -u "$bmc_user" -p "$bmc_password" -r "$host" config -g cfgServerInfo -o cfgServerFirstBootDevice PXE

  sleep 2

  /opt/dell/srvadmin/sbin/racadm -u "$bmc_user" -p "$bmc_password" -r "$host" serveraction powerup

done

exit 0
