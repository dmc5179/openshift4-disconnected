#!/bin/env python3

import argparse
import json
import shutil

from ansible.module_utils.basic import AnsibleModule

ANSIBLE_METADATA = {
    'metadata_version': '1.1',
    'status': ['preview'],
    'supported_by': 'community'
}

DOCUMENTATION = '''
---
module: ignition_systemd_patch

short_description: Patch ignition files with additional systemd settings

version_added: "2.4"

description:
    - "This is my longer description explaining my test module"

options:
    name:
        description:
            - This is the message to send to the test module
        required: true
    new:
        description:
            - Control to demo if the result of this module is changed or not
        required: false

author:
    - Dan Clark (@dmc5179)
'''

EXAMPLES = '''
# Pass in a message
- name: Test with a message
  my_test:
    name: hello world

# pass in a message and have changed true
- name: Test with a message and changed output
  my_test:
    name: hello world
    new: true

# fail the module
- name: Test failure of the module
  my_test:
    name: fail me
'''

RETURN = '''
original_message:
    description: The original name param that was passed in
    type: str
    returned: always
message:
    description: The output message that the test module generates
    type: str
    returned: always
'''


__version__ ='0.1.0'

def main():

    global module

    module = AnsibleModule(
        argument_spec=dict(
            src=dict(type='path', required=True),
            patch=dict(type='path', required=True),
            backup=dict(type='bool', default=False)
        ),
        supports_check_mode=False,
    )

    if module.params['backup'] == True:
      shutil.copy(module.params['src'], module.params['src'] + ".backup")

    d1 = json.load(open(module.params['src'],'r'))
    d2 = json.load(open(module.params['patch'],'r'))

    # If the systemd section has nothing in it then we cannot use +=
    # And we have to use =
    if len(d1["systemd"]) == 0:
      d1["systemd"] = d2["systemd"]
    else:
      d1["systemd"]["units"] += d2["systemd"]["units"]

    with open(module.params['src'], 'w') as filetowrite:
      filetowrite.write(json.dumps(d1))

    result = {'dest': module.params['src']}
    result['path'] = module.params['src']
    result['changed'] = d1

    module.exit_json(**result)


if __name__ == '__main__':
    main()
