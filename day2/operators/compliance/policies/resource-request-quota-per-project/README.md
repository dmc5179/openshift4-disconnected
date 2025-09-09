# Resource Request Quotas Per Project 

- Ensure workloads use resource requests and limits per namespace.  
- Resource quotas provide constraints that limit aggregate resource consumption per project. This helps prevent resource starvation. When deploying your application, it is important to tune based on memory and CPU consumption, allocating enough resources  for the application to function properly.

- To get all the non-control plane namespaces, you can do the following command 

```console
oc get  namespaces -o json | jq '[.items[] | select((.metadata.name | startswith("openshift") | not) and (.metadata.name | startswith("kube-") | not) and .metadata.name != "default" and .metadata.name != "rhacs-operator" and (true)) | .metadata.name]'
```

- To get all the non-control plane namespaces with a ResourceQuota, you can do the following command

```console 
oc get --all-namespaces resourcequota -o json | jq '[.items[] | select((.metadata.namespace | startswith("openshift") | not) and (.metadata.namespace | startswith("kube-") | not) and .metadata.namespace != "default" and .metadata.namespace != "rhacs-operator" and (true)) | .metadata.namespace] | unique'
```

- For compliance ensure that all non-control plan namespaces have a resource quota and limit range applied.  ** NOTE: configure the namespace quota and limit ranges according to the neads of the applications, you can adjust these as needed **
- In this repo there are example resource quota and limit range yamls, apply them to the needed namespace 

```console
oc create -f limit-range-project-compliance.yaml -n <namespace>

oc create -f resource-quota-project-compliance.yaml -n <namespace>
```

- Verify resource quota nd limit ranges exist in the above namespace 

```console
oc get limitranges -n <namespace>

oc get quota -n <namespace>
```
