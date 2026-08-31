# Efficient LDAP Sync CronJob Setup — Single Source of Truth

## The Problem

The official OpenShift docs for "Automatically syncing LDAP groups" have you
create a ConfigMap by embedding the LDAP sync YAML inside another YAML manifest.
This means maintaining the LDAP config in two places — the original augmented AD
config file and the ConfigMap manifest.

## The Solution

Use `oc create configmap --from-file` to create the ConfigMap directly from your
existing augmented AD config YAML. Pair it with a Secret for the bind password.
You maintain **one file** — your augmented AD config — and derive everything else
from it.

---

## Prerequisites

- A working augmented Active Directory LDAP sync config YAML (e.g.,
  `augmented-ad-config.yaml`)
- The `bindPassword` field in that YAML must use `file:` to reference a mounted
  path (not a literal password)
- `oc` CLI logged in with cluster-admin privileges

## Step-by-Step

### 1. Prepare Your Augmented AD Config YAML

Your single config file should reference the bind password from a file path
that will exist inside the CronJob pod (mounted from a Secret). Set
`bindPassword` to read from `/etc/secrets/bindPassword`:

```yaml
kind: LDAPSyncConfig
apiVersion: v1
url: ldaps://ad.example.com:636
bindDN: "CN=svc-openshift,OU=ServiceAccounts,DC=example,DC=com"
bindPassword:
  file: /etc/secrets/bindPassword
ca: /etc/ldap-ca/ca-bundle.crt
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

> This is your **single source of truth**. All OpenShift resources are created
> from this file.

### 2. Create the Namespace

```bash
oc new-project ldap-sync
```

### 3. Create the Secret (Bind Password)

```bash
oc create secret generic ldap-secret \
  --from-literal=bindPassword='YourP@ssword!' \
  -n ldap-sync
```

> **Important:** Use single quotes around the password to prevent shell
> interpretation of special characters (`$`, `!`, `#`).
> See [Red Hat Solution 7022881](https://access.redhat.com/solutions/7022881).

### 4. Create the ConfigMap From Your Existing Config File

Instead of writing a ConfigMap manifest that embeds the YAML, create it directly:

```bash
oc create configmap ldap-group-syncer \
  --from-file=sync.yaml=augmented-ad-config.yaml \
  -n ldap-sync
```

This mounts the contents of `augmented-ad-config.yaml` as the key `sync.yaml`
inside the ConfigMap. The CronJob will mount it at `/etc/config/sync.yaml`.

**When you update the config**, just replace the ConfigMap:

```bash
oc create configmap ldap-group-syncer \
  --from-file=sync.yaml=augmented-ad-config.yaml \
  --dry-run=client -o yaml | oc apply -f - -n ldap-sync
```

### 5. Create the CA Bundle ConfigMap (If Using LDAPS)

If your LDAP server uses TLS with a custom CA:

```bash
oc create configmap ldap-ca \
  --from-file=ca-bundle.crt=/path/to/your/ca-bundle.crt \
  -n ldap-sync
```

### 6. Create the Service Account and Cluster Role Binding

```yaml
# ldap-sync-rbac.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ldap-group-syncer
  namespace: ldap-sync
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ldap-group-syncer
rules:
- apiGroups: ["user.openshift.io"]
  resources: ["groups"]
  verbs: ["get", "list", "create", "update", "patch", "delete"]
- apiGroups: ["user.openshift.io"]
  resources: ["users", "identities", "useridentitymappings"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ldap-group-syncer
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ldap-group-syncer
subjects:
- kind: ServiceAccount
  name: ldap-group-syncer
  namespace: ldap-sync
```

```bash
oc apply -f ldap-sync-rbac.yaml
```

### 7. Create the CronJob

```yaml
# ldap-sync-cronjob.yaml
kind: CronJob
apiVersion: batch/v1
metadata:
  name: ldap-group-syncer
  namespace: ldap-sync
spec:
  schedule: "*/30 * * * *"
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      backoffLimit: 0
      ttlSecondsAfterFinished: 1800
      template:
        spec:
          serviceAccountName: ldap-group-syncer
          restartPolicy: Never
          terminationGracePeriodSeconds: 30
          activeDeadlineSeconds: 500
          dnsPolicy: ClusterFirst
          containers:
          - name: ldap-group-sync
            image: "registry.redhat.io/openshift4/ose-cli:latest"
            command:
            - "/bin/bash"
            - "-c"
            - "oc adm groups sync --sync-config=/etc/config/sync.yaml --confirm"
            volumeMounts:
            - name: ldap-sync-volume
              mountPath: /etc/config
              readOnly: true
            - name: ldap-bind-password
              mountPath: /etc/secrets
              readOnly: true
            - name: ldap-ca
              mountPath: /etc/ldap-ca
              readOnly: true
          volumes:
          - name: ldap-sync-volume
            configMap:
              name: ldap-group-syncer
          - name: ldap-bind-password
            secret:
              secretName: ldap-secret
          - name: ldap-ca
            configMap:
              name: ldap-ca
```

```bash
oc apply -f ldap-sync-cronjob.yaml
```

> **Note:** The `command` must be on a single line after `-c`.
> See [Red Hat Solution 6597481](https://access.redhat.com/solutions/6597481)
> for the correct syntax.

### 8. Test It

Trigger a manual run:

```bash
oc create job ldap-sync-test --from=cronjob/ldap-group-syncer -n ldap-sync
```

Check the logs:

```bash
oc logs -f job/ldap-sync-test -n ldap-sync
```

Verify the groups were created:

```bash
oc get groups
```

---

## How the Pieces Fit Together

```
augmented-ad-config.yaml        (your single source file)
        │
        ├──► oc create configmap --from-file=sync.yaml=augmented-ad-config.yaml
        │         └──► ConfigMap: ldap-group-syncer
        │                  mounted at /etc/config/sync.yaml
        │
        │    (config YAML says: bindPassword.file: /etc/secrets/bindPassword)
        │
        └──► oc create secret --from-literal=bindPassword='...'
                  └──► Secret: ldap-secret
                           mounted at /etc/secrets/bindPassword

CronJob mounts both volumes into the pod:
  /etc/config/sync.yaml    ← ConfigMap (your augmented AD config)
  /etc/secrets/bindPassword ← Secret (bind password)
  /etc/ldap-ca/ca-bundle.crt ← ConfigMap (CA cert, if using LDAPS)
```

## Updating the Config

When you change `augmented-ad-config.yaml`, update the ConfigMap in one command:

```bash
oc create configmap ldap-group-syncer \
  --from-file=sync.yaml=augmented-ad-config.yaml \
  --dry-run=client -o yaml | oc apply -f - -n ldap-sync
```

No second file to maintain. The next CronJob run picks up the change
automatically (ConfigMap volumes are updated by the kubelet).

## Rotating the Bind Password

```bash
oc create secret generic ldap-secret \
  --from-literal=bindPassword='NewP@ssword!' \
  --dry-run=client -o yaml | oc apply -f - -n ldap-sync
```

---

## Quick Reference — Files You Maintain

| File | Purpose | Stored As |
|---|---|---|
| `augmented-ad-config.yaml` | LDAP sync config (single source of truth) | ConfigMap via `--from-file` |
| `ldap-sync-rbac.yaml` | ServiceAccount, ClusterRole, ClusterRoleBinding | Applied directly |
| `ldap-sync-cronjob.yaml` | CronJob definition | Applied directly |
| *(none — CLI only)* | Bind password | Secret via `--from-literal` |
| *(none — CLI only)* | CA certificate | ConfigMap via `--from-file` |

## References

- [Red Hat Solution 7125347](https://access.redhat.com/solutions/7125347) — CA bundle in CronJob (full CronJob example with all volume mounts)
- [Red Hat Solution 6597481](https://access.redhat.com/solutions/6597481) — Correct command syntax in CronJob
- [Red Hat Solution 7022881](https://access.redhat.com/solutions/7022881) — Special characters in bind password secrets
- [Red Hat Solution 4993881](https://access.redhat.com/solutions/4993881) — Running LDAP sync without cluster-admin
- [OpenShift Docs: Syncing LDAP Groups](https://docs.openshift.com/container-platform/latest/authentication/ldap-syncing.html)
