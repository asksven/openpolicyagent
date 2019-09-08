# Namespaces require certain labels

`k8srequiredlabels_template.yaml` contains a `ConstraintTemplate` defining that objects require certain labels.

`all_ns_must_have_gatekeeper.yaml` defines the rule that namespaces must have a label `gatekeeper`

1. Deploy: `kubectl apply -f k8srequiredlabels_template.yaml` and `kubectl apply -f all_ns_must_have_gatekeeper.yaml`
2. Test: `kubectl create ns test` fails with `Error from server ([denied by ns-must-have-gk] you must provide labels: {"gatekeeper"}): admission webhook "validation.gatekeeper.sh" denied the request: [denied by ns-must-have-gk] you must provide labels: {"gatekeeper"}`
3. Test again (succeeding this time):
```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  labels:
    gatekeeper: "yes"
  name: test
apiVersion: v1
EOF
```
