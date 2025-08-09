# Adding RHEL worker nodes

- RHEL 8.8 and above are supported through 4.18

- RHEL 9 appears to have never gained full support

- RHEL worker node support appears to be remove in OpenShift 4.19 and above

- When installing RHEL, select "minimal server" and then select "container management tools"
- Ensure there is no swap partition, add its space to root volume if possible
- Remove home partition, add storage to root volume if possible
