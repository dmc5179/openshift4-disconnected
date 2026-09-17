from __future__ import absolute_import, division, print_function

__metaclass__ = type

DOCUMENTATION = """
  name: rfc1123
  short_description: Converts an input string to an RFC1123 compatible value
  version_added: 1.0.0
  author: Andrew Block (@ablock)
  description:
    - Converts an input string to an RFC1123 compatible value.
  options:
    _input:
      description: Input value.
      type: string
      required: false
    prefix:
      description: A prefix to add
      type: string
      required: false
    prefix_condition:
      description: >
        A regex describing when to use the prefix, this condition is
        evaluated after after replacing special characters and leading
        and trailing '-'
      type: string
      required: false
"""

EXAMPLES = """
- name: Convert to RFC1123
  ansible.builtin.debug:
    msg: "{{ 'My_value' | infra.openshift_virtualization_migration.rfc1123 }}"

- name: Convert to RFC1123 and add a prefix of "hello-"
  ansible.builtin.debug:
    msg: "{{ 'My_value' | infra.openshift_virtualization_migration.rfc1123('hello-') }}"

- name: Convert to RFC1123 and add a prefix of "hello-" when the regex '^[0-9]' matches
  ansible.builtin.debug:
    msg: "{{ 'My_value' | infra.openshift_virtualization_migration.rfc1123('hello-', '^[0-9]+') }}"
"""

RETURN = """
  _value:
    description: The formatted RFC1123 string.
    type: string
"""

import re


def rfc1123(value, prefix="", prefix_condition=r"^"):
    # Replace all characters that are not alphanumeric (A-Z, a-z, 0-9) with a hyphen
    result = re.sub(r"[^A-Z\d]", "-", value, flags=re.IGNORECASE)
    # Remove leading hyphens
    result = re.sub(r"^-+", "", result)
    # Remove trailing hyphens
    result = re.sub(r"-+$", "", result)

    # If the prefix is set, add a prefix.
    # This can be used for scenarios that cannot start with a number
    if re.match(prefix_condition, result) is not None:
        result = prefix + result

    # Replace multiple consecutive hyphens with a single hyphen
    result = re.sub(r"-+", "-", result)

    return result.lower()[:63]  # force to lower and return at most 63 characters


class FilterModule(object):
    """Filter to convert string to rfc1123"""

    def filters(self):
        filters = {
            "rfc1123": rfc1123,
        }

        return filters
