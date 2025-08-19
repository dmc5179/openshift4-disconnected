# Deploying OpenShift Lightspeed for offline environments

- Note, a GPU resource is highly preferred. Without one OLS will take forever to respond or may never respond

## Install OpenShift lightspeed operator from the operator hub

## Create kube secret with API creds to the model. Even fake creds
```
oc create -f ols-kubesec.yaml
```

## Deploy an instance of OpenShift lightspeed

- ols-config.yaml contains settings for the Model's API URL and type along with resource usage for OLS

```
oc create -f ols-config.yaml
```
