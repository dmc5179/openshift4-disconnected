## Pipeline Configuration for Gitlab

In order for this pipeline to pull the required content you must have CI/CD variables set at the group or project level.

| Key | Variable Type | Visibility | Flags | Description | Key | Value |
| --- | ------------- | ---------- | ----- | ----------- | --- | ----- |
| ANSIBLE_GALAXY_SERVER_LIST | Variable | Visible | None | Ansible Galaxy Sources | automation_hub,upstream_galaxy |
| ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_CERTIFIED_AUTH_URL | Variable | Visible | None | Downstream Ansible Galaxy Auth Url | https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token |
| ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_CERTIFIED_TOKEN | Variable | Masked and hidden |  None | Automation Hub Certified Token | abcdefghijklmnop... |
| ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_CERTIFIED_URL | Variable | Visible | None | Downstream Ansible Certified Galaxy URL | https://console.redhat.com/api/automation-hub/content/published/ |
| ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_VALIDATED_AUTH_URL | Variable | Visible | None | Downstream Ansible Certified Galaxy Auth Url | https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token |
| ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_VALIDATED_TOKEN | Variable | Masked and hidden |  None | Automation Hub Validated Token | abcdefghijklmnop... |
| ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_VALIDATED_URL | Variable | Visible | None | Downstream Ansible Validated Galaxy URL | https://console.redhat.com/api/automation-hub/content/validated/ |
| ANSIBLE_GALAXY_SERVER_UPSTREAM_GALAXY_URL | Variable | Visible | None | Upstream Ansible Validated Galaxy URL  | https://galaxy.ansible.com/ |
