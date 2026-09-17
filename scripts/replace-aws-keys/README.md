# Replace AWS API credentials for some cluster deployments

## How to find CredentialsRequests if needed
```bash
REQUESTS=$(oc get --no-headers=true -n openshift-cloud-credential-operator -o custom-columns=":metadata.name" CredentialsRequest)
for r in ${REQUESTS}
do
  type=$(oc get -o yaml CredentialsRequest $r -n openshift-cloud-credential-operator | yq '.status.conditions[0].type')
  if [[ "${type}" == "Ignored" ]]
  then
    continue
  fi
  echo "Not ignore: $r"
done
```

## For Passthrough mode clusters

- Set your AWS vars in your shell like
```bash
export AWS_ACCESS_KEY_ID=""
export AWS_DEFAULT_REGION="us-east-2"
export AWS_SECRET_ACCESS_KEY=
```

- Run the script
```bash
./replace-aws-keys.sh
```
