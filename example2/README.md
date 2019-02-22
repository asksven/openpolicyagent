# Build a policy to avoid deleting of "protected" namespaces


This example created a policy that fails attempts to delete a namespace annotated with `protected: "yes"`

1. Create the policy: `kubectl -n opa create configmap protected-namespaces --from-file=protected-namespaces.rego`
1. Create a namespace with the annotation: `kubectl apply -f protected-namespace.yaml`
1. Check if the namespace has the annotation `protected=yes`: `kubectl describe ns production`
1. 