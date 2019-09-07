# Install open policy agent

Instructions: https://www.openpolicyagent.org/docs/latest/kubernetes-admission-control#1-start-kubernetes-recommended-admisson-controllers-enabled

Create namespace: `kubectl create ns opa`

Create CA and certificate/key pair for opa:

```
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -days 100000 -out ca.crt -subj "/CN=admission_ca"
```

Generate the TLS key and certificate:

```
cat >server.conf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, serverAuth
EOF
```

```
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr -subj "/CN=opa.opa.svc" -config server.conf
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 100000 -extensions v3_req -extfile server.conf
```

Create a Secret to store the TLS credentials:

```
kubectl -n opa create secret tls opa-server --cert=server.crt --key=server.key
```

Create the adminission controller:

```
kubectl apply -f admission-controller.yaml
```

Finally register the adminission controller:


Create the webhook configuration:

```
cat > webhook-configuration.yaml <<EOF
kind: ValidatingWebhookConfiguration
apiVersion: admissionregistration.k8s.io/v1beta1
metadata:
  name: opa-validating-webhook
webhooks:
  - name: validating-webhook.openpolicyagent.org
    namespaceSelector:
      matchExpressions:
      - key: openpolicyagent.org/webhook
        operator: NotIn
        values:
        - ignore
    rules:
      - operations: ["CREATE", "UPDATE"]
        apiGroups: ["*"]
        apiVersions: ["*"]
        resources: ["*"]
    clientConfig:
      caBundle: $(cat ca.crt | base64 | tr -d '\n')
      service:
        namespace: opa
        name: opa
EOF
```

**Note:** the webhook from the doc was modified to get triggered on `DELETE` as well, since we want to provide namespace deletion on `example2`

Make sure to exclude `kube-system` and `opa`:

```
kubectl label ns kube-system openpolicyagent.org/webhook=ignore
kubectl label ns opa openpolicyagent.org/webhook=ignore
```

kubectl apply -f webhook-configuration.yaml

## Test

Check the logs: `kubectl -n opa logs -l app=opa -c opa`


For building an own policy see `example1/README.md`

