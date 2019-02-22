# Testing opa

`ingress-conflicts.rego` contains the example from §4 of  https://www.openpolicyagent.org/docs/kubernetes-admission-control.html

1. Create a configmap: `kubectl -n opa create configmap ingress-whitelist --from-file=ingress-whitelist.rego`
2. Create the two namespaces: 
```
kubectl create -f qa-namespace.yaml
kubectl create -f production-namespace.yaml
```
3. Try creating the ingresses
```
kubectl create -f ingress-ok.yaml -n production
kubectl create -f ingress-bad.yaml -n qa
```

The creation of `ingress-bad.yaml` sould fail with:

```
Error from server (invalid ingress host "acmecorp.com"): error when creating "ingress-bad.yaml": admission webhook "validating-webhook.openpolicyagent.org" denied the request: invalid ingress host "acmecorp.com"
```

