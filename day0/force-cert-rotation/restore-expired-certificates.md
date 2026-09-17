# Restoring expired certificates on an OpenShift cluster

## Gain access to one of the control plane nodes

## Approve any pending CSRs:

```console
function approvecsrs {
while true
do
  echo -n "Checking for CSRs: "
  date
  if [[ $(oc get -A csr | grep -i pending | wc -l) > 0 ]]
  then
    oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' | xargs -r -P 1 -n 20 oc adm certificate approve
  fi
  sleep 10
done
}
export -f approvecsrs


```
