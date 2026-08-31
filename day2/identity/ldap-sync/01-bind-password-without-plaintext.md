# Running `oc adm groups sync` Without a Plaintext Bind Password

## The Problem

The augmented Active Directory LDAP sync config YAML requires a `bindPassword`
field, but you don't want to store the password in plaintext in the file.

## Options

OpenShift's `bindPassword` field accepts a **StringSource**, which means it
supports four forms — not just a raw string. The three alternatives to plaintext
are: environment variable, file reference, and encrypted file + key.

---

### Option 1: Environment Variable (Simplest for CLI Use)

Set `bindPassword` to reference an environment variable instead of a literal
value.

**In your augmented AD config YAML:**

```yaml
kind: LDAPSyncConfig
apiVersion: v1
url: ldaps://ad.example.com:636
bindDN: "CN=svc-openshift,OU=ServiceAccounts,DC=example,DC=com"
bindPassword:
  env: LDAP_BIND_PASSWORD
ca: /path/to/ca-bundle.crt
insecure: false
augmentedActiveDirectory:
  groupsQuery:
    baseDN: "OU=Groups,DC=example,DC=com"
    scope: sub
    derefAliases: never
    pageSize: 0
  groupUIDAttribute: dn
  groupNameAttributes: [ cn ]
  usersQuery:
    baseDN: "OU=Users,DC=example,DC=com"
    scope: sub
    derefAliases: never
    filter: "(objectClass=person)"
    pageSize: 0
  userNameAttributes: [ sAMAccountName ]
  groupMembershipAttributes: [ "memberOf:1.2.840.113556.1.4.1941:" ]
```

**Run the sync:**

```bash
LDAP_BIND_PASSWORD='YourP@ssword!' oc adm groups sync --sync-config=augmented-ad-config.yaml --confirm
```

Or export it first:

```bash
export LDAP_BIND_PASSWORD='YourP@ssword!'
oc adm groups sync --sync-config=augmented-ad-config.yaml --confirm
```

> **Tip:** Use single quotes around the password to avoid shell interpretation
> of special characters (`$`, `!`, `#`, etc.).

---

### Option 2: File Reference (Read Password from a File)

Point `bindPassword` at a file on disk that contains only the password.

**Create the password file:**

```bash
echo -n 'YourP@ssword!' > /secure/path/bindpassword.txt
chmod 600 /secure/path/bindpassword.txt
```

**In your augmented AD config YAML:**

```yaml
bindPassword:
  file: /secure/path/bindpassword.txt
```

**Run the sync:**

```bash
oc adm groups sync --sync-config=augmented-ad-config.yaml --confirm
```

> The `file:` path must be absolute, or relative to the working directory — not
> relative to the YAML file location. See
> [Red Hat Solution 4897671](https://access.redhat.com/solutions/4897671).

---

### Option 3: Encrypted File + Key (`oc adm ca encrypt`)

Encrypt the password so that neither the YAML nor any file on disk contains
plaintext.

**Step 1 — Generate the encrypted password and key:**

```bash
oc adm ca encrypt --genkey=/secure/path/bindPassword.key --out=/secure/path/bindPassword.encrypted
```

You will be prompted to enter the bind password. This produces two files:
- `bindPassword.key` — the encryption key
- `bindPassword.encrypted` — the encrypted password

**Step 2 — Reference both files in your augmented AD config YAML:**

```yaml
bindPassword:
  file: /secure/path/bindPassword.encrypted
  keyFile: /secure/path/bindPassword.key
```

**Step 3 — Run the sync:**

```bash
oc adm groups sync --sync-config=augmented-ad-config.yaml --confirm
```

> **Important:** Use **full absolute paths** for both `file:` and `keyFile:`.
> Relative paths cause the error `could not read file: stat ... not a directory`.
> See [Red Hat Solution 4897671](https://access.redhat.com/solutions/4897671).

---

### Option 4: Kubernetes Secret (For CronJob / Automated Use)

This approach is covered in detail in
[02-efficient-cronjob-setup.md](02-efficient-cronjob-setup.md), but the short
version: mount a Kubernetes Secret as a volume into the CronJob pod. The sync
config YAML uses `bindPassword: file: /etc/secrets/bindPassword` and the
CronJob volume mount makes the secret key available at that path.

---

## Which Option to Use?

| Scenario | Recommended Option |
|---|---|
| **One-off CLI run** (testing, dry run) | `env:` — quick, no files to manage |
| **Scripted/automated CLI runs** on a bastion host | `file:` or encrypted `file:` + `keyFile:` |
| **CronJob running inside OpenShift** | Kubernetes Secret mounted as a volume file (see [part 2](02-efficient-cronjob-setup.md)) |
| **Maximum local security** (admin workstation) | Encrypted `file:` + `keyFile:` via `oc adm ca encrypt` |

## Dry Run First

Regardless of which option you choose, always dry-run before applying:

```bash
oc adm groups sync --sync-config=augmented-ad-config.yaml
```

(Omit `--confirm` to see what would be synced without making changes.)

## References

- [Red Hat Solution 4897671](https://access.redhat.com/solutions/4897671) — `bindPassword.file` must use full paths
- [Red Hat Solution 3514971](https://access.redhat.com/solutions/3514971) — How to encrypt LDAP password with `oc adm ca encrypt`
- [Red Hat Solution 7022881](https://access.redhat.com/solutions/7022881) — Special characters in bind password (use single quotes when creating secrets)
- [OpenShift Docs: Syncing LDAP Groups](https://docs.openshift.com/container-platform/latest/authentication/ldap-syncing.html)
