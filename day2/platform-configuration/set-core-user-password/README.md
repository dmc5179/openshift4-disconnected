# Setting core user password

- Create hashed password for the core user
```bash
PASS_HASH=$(echo $(printf 'MYPASSWORD' | openssl passwd -6 --stdin))
```

- Apply the core user password to control plane nodes
```bash
cat core-user-set-password-master.bu | sed "s|MYPASSWORDHASH|${PASS_HASH}|g" | butane | oc create -f -
```

- Apply the core user password to worker nodes
```bash
cat core-user-set-password-worker.bu | sed "s|MYPASSWORDHASH|${PASS_HASH}|g" | butane | oc create -f -
```

- Docs link
https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/machine_configuration/machine-configs-configure#core-user-password_machine-configs-configure


