ocp_upgrade
=========

Commands to upgrade and OpenShift 4 cluster in a disconnected environment

```
oc adm upgrade --allow-explicit-upgrade=true --allow-upgrade-with-warnings=true --to-image='quay.io/openshift-release-dev/ocp-release@sha256:e1ebc7295248a8394afb8d8d918060a7cc3de12c491283b317b80b26deedfe61' --force=true

Updating to release image quay.io/openshift-release-dev/ocp-release@sha256:e1ebc7295248a8394afb8d8d918060a7cc3de12c491283b317b80b26deedfe61

oc get clusterversion -o json|jq ".items[0].status.history"
[
  {
    "completionTime": null,
    "image": "quay.io/openshift-release-dev/ocp-release@sha256:e1ebc7295248a8394afb8d8d918060a7cc3de12c491283b317b80b26deedfe61",
    "startedTime": "2020-05-12T14:10:33Z",
    "state": "Partial",
    "verified": false,
    "version": "4.3.13"
  },
  {
    "completionTime": "2020-05-12T13:27:08Z",
    "image": "quay.io/openshift-release-dev/ocp-release@sha256:75e8f20e9d5a8fcf5bba4b8f7d17057463e222e350bcfc3cf7ea2c47f7d8ba5d",
    "startedTime": "2020-05-12T13:08:28Z",
    "state": "Completed",
    "verified": false,
    "version": "4.3.12"
  }
]
```

Requirements
------------

Any pre-requisites that may not be covered by Ansible itself or the role should be mentioned here. For instance, if the role uses the EC2 module, it may be a good idea to mention in this section that the boto package is required.

Role Variables
--------------

A description of the settable variables for this role should go here, including any variables that are in defaults/main.yml, vars/main.yml, and any variables that can/should be set via parameters to the role. Any variables that are read from other roles and/or the global scope (ie. hostvars, group vars, etc.) should be mentioned here as well.

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

License
-------

BSD

Author Information
------------------

Dan Clark <danclark@redhat.com>
