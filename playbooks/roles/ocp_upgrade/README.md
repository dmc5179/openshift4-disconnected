# Ansible role 'ocp_upgrade'

Commands to upgrade and OpenShift 4 cluster in a disconnected environment

## Requirements

- No Requirements

## Dependencies

- No Dependencies

## Role Variables

| Variable                                     | Default                       | Comments                                                                                |
| :---                                         | :---                          | :---                                                                                    |

## Example Playbook

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

## License

2-clause BSD license, see [LICENSE.md](LICENSE.md)

## Contributors

- [Dan Clark](https://github.com/dmc5179/) (maintainer)
