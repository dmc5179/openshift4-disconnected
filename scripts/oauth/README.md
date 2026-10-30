# OAuth helpers

- `oauth-client.yaml`: OpenShift `OAuthClient` for an external app that logs in with OpenShift.
- `oauth2_generic.yaml`: GitLab OmniAuth "OAuth2 Generic" provider that uses OpenShift as the
  identity provider. Load it into GitLab as a secret:

  ```bash
  oc create secret generic -n gitlab-system gitlab-oauth2-generic --from-file=provider=oauth2_generic.yaml
  ```
- `client.py`: generates a random client secret and its SHA256 hash for `oauth-client.yaml`.
- `ipa.sh`, `ldap_sync.sh`: FreeIPA / LDAP identity provider and group sync helpers.
  For LDAP group sync configs, see `day2/identity/ldap-sync/`.
