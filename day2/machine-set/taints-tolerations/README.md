# Tainting nodes for use by specific teams

## Define the group name
```console
export OCP_GROUP_NAME="team-a-dev"
```

## Taint the node

```console
oc adm taint nodes <node-name> dedicated=${OCP_GROUP_NAME}:NoSchedule
```

## Create team namespace

```console
oc new-project ${OCP_GROUP_NAME}-workload
```

## Configure Namespace tolerations

```console
oc annotate namespace ${OCP_GROUP_NAME}-workload \
openshift.io/node-selector='dedicated=${OCP_GROUP_NAME}' \
scheduler.alpha.kubernetes.io/defaultTolerations='[{"key": "dedicated", "operator": "Equal", "value": "${OCP_GROUP_NAME}", "effect": "NoSchedule"}]'
```

- Note: The openshift.io/node-selector ensures pods must go to that node, while the defaultTolerations ensures they can go to that node by matching the taint.

## Restrict access to group

```console
oc adm policy add-role-to-group edit ${OCP_GROUP_NAME} -n ${OCP_GROUP_NAME}-workload
```
