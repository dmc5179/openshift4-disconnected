<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [ansible-openvswitch](#ansible-openvswitch)
  - [Requirements](#requirements)
  - [Role Variables](#role-variables)
  - [Dependencies](#dependencies)
  - [Example Playbook](#example-playbook)
  - [License](#license)
  - [Author Information](#author-information)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# ansible-openvswitch

An [Ansible](https://www.ansible.com) role to install/configure [Open vSwitch](http://openvswitch.org/)

## Requirements

None

## Role Variables

```yaml
---
# defaults file for ansible-openvswitch

openvswitch_bridges: []
  # - bridge: 'br-int'
  #   state: 'present'

openvswitch_packages:
  - 'openvswitch'
  - 'python3-openvswitch'

openvswitch_ports: []
  # - bridge: 'br-int'
  #   ports:
  #     - port: 'enp0s9'
  #       state: 'present'
  #     - port: 'enp0s10'
  #       state: 'present'

openvswitch_system_tuning: []
  # - name: 'net.ipv4.ip_forward'
  #   value: 1
```

## Dependencies

-   [ansible-config-interfaces](https://github.com/mrlesmithjr/ansible-config-interfaces)

## Example Playbook

## License

MIT

## Author Information
