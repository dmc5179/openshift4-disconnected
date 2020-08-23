# Main Inventory File

- Copy the file playbooks/inventory.example to playbooks/inventory

- By default the inventory is configured such that all services will run on the same host "local"

- For the mirroring portion of this guide only the "registry_server" host of the inventory file is important. If this playbook set will be run on the host that
will host the mirror registry then nothing more needs to be done. Make sure that the permissions are correct to allow the user that will run the playbooks to become root on
the target hosts.