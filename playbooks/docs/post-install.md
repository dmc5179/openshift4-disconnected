# Post Install Procedure

## Disable OperatorHub

- In a disconnected (air-gap) environment the OperatorHub that ships and installs with the cluster will need to be disabled and replaced with a disconnected version


## Configure Chrony Time Server

- If the OpenShift nodes receive their IP addresses from a DHCP server which also includes timeserver information in the DHCP response then there is nothing to do. When using a static IP configuration, or the DHCP server does not provide the time server information, use the following procedure to set the time server for all OpenShift cluster hosts.


