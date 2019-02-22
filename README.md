# Install open policy agent

Instructions: https://www.openpolicyagent.org/docs/kubernetes-admission-control.html

Create namespace: `kubectl create namespace opa`

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
kubectl create secret tls opa-server --cert=server.crt --key=server.key
```

Create the adminission controller:

```
kubectl apply -f admission-controller.yaml
```

Finally registry the adminission controller:

```
kubectl apply -f webhook-configuration.yaml
```

## Test

For building an own policy see `example1/README.md`

