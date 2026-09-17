# Tainting nodes for use by specific teams

## Define the group name
```bash
export OCP_GROUP_NAME="team-a-dev"
```

## Taint the node

```bash
oc adm taint nodes <node-name> dedicated=${OCP_GROUP_NAME}:NoSchedule
```

## Create team namespace

```bash
oc new-project ${OCP_GROUP_NAME}-workload
```

## Configure Namespace tolerations

```bash
oc annotate namespace ${OCP_GROUP_NAME}-workload \
openshift.io/node-selector='dedicated=${OCP_GROUP_NAME}' \
scheduler.alpha.kubernetes.io/defaultTolerations='[{"key": "dedicated", "operator": "Equal", "value": "${OCP_GROUP_NAME}", "effect": "NoSchedule"}]'
```

- Note: The openshift.io/node-selector ensures pods must go to that node, while the defaultTolerations ensures they can go to that node by matching the taint.

## Restrict access to group

```bash
oc adm policy add-role-to-group edit ${OCP_GROUP_NAME} -n ${OCP_GROUP_NAME}-workload
```
