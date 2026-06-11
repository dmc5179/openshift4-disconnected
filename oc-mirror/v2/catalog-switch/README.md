# Catalog switch

## Here is the current catalog configured for devspaces.
```
oc get subs -n openshift-operators
NAME                                                                              PACKAGE                 SOURCE                           CHANNEL
devspaces                                                                         devspaces               cs-redhat-operator-index-v4-20   stable
devworkspace-operator-fast-cs-redhat-operator-index-v4-20-openshift-marketplace   devworkspace-operator   cs-redhat-operator-index-v4-20   fast
web-terminal                                                                      web-terminal            redhat-operators                 fast
```

## Here is a snippet from the devspaces operator before the catalog change
```

oc describe operator devspaces.openshift-operators


      Kind:                    ClusterServiceVersion
      Name:                    devspacesoperator.v3.27.1
      Namespace:               openshift-operators


  Conditions:
        Last Transition Time:  2026-06-01T16:34:29Z
        Message:               all available catalogsources are healthy
        Reason:                AllCatalogSourcesHealthy
        Status:                False
        Type:                  CatalogSourcesUnhealthy
      Kind:                    Subscription
      Name:                    devspaces
      Namespace:               openshift-operators
```


## Command to change the catalog source for devspaces to redhat-operators:

```
oc patch subs -n openshift-operators devspaces -p '{"spec":{"source":"redhat-operators"}}' --type=merge

Updated subs
NAME                                                                              PACKAGE                 SOURCE                           CHANNEL
devspaces                                                                         devspaces               redhat-operators                 stable
devworkspace-operator-fast-cs-redhat-operator-index-v4-20-openshift-marketplace   devworkspace-operator   cs-redhat-operator-index-v4-20   fast
web-terminal                                                                      web-terminal            redhat-operators                 fast

updated devspaces operator 

      Kind:                    ClusterServiceVersion
      Name:                    devspacesoperator.v3.28.2
      Namespace:               openshift-operators
      API Version:             apiextensions.k8s.io/v1

      Conditions:
        Last Transition Time:  2026-06-01T16:34:29Z
        Message:               all available catalogsources are healthy
        Reason:                AllCatalogSourcesHealthy
        Status:                False
        Type:                  CatalogSourcesUnhealthy
      Kind:                    Subscription
      Name:                    devspaces
      Namespace:               openshift-operators
```
