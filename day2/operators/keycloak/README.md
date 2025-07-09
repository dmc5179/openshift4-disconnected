# Deploy the postgres database
```shell
oc create -f postgres.yaml
```

# Create secret with postgres username/password
```shell
oc create secret generic keycloak-db-secret \
  --from-literal=username=[your_database_username] \
  --from-literal=password=[your_database_password]
```

# Check keycloak status
```shell
oc get keycloaks/keycloak -o go-template='{{range .status.conditions}}CONDITION: {{.type}}{{"\n"}}  STATUS: {{.status}}{{"\n"}}  MESSAGE: {{.message}}{{"\n"}}{{end}}'
```

# Extract default username and password
```shell
oc get secret keycloak-initial-admin -o jsonpath='{.data.username}' | base64 --decode
oc get secret keycloak-initial-admin -o jsonpath='{.data.password}' | base64 --decode
```
