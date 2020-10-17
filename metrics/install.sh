#!/bin/bash
set -euxo pipefail

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.7/components.yaml

# patch metrics server to fix issue [#131](https://github.com/kubernetes-incubator/metrics-server/issues/131)
kubectl -n kube-system patch deploy metrics-server -p '{"spec":{"template":{"spec":{"containers":[{"name":"metrics-server","command":["/metrics-server","--kubelet-insecure-tls","--kubelet-preferred-address-types=InternalIP"]}]}}}}'
kubectl -n kube-system wait --timeout=300s --for=condition=available deploy --all

echo "  ____________________________________________________"
echo ".:| Wait ~1min then type command 'kubectl top nodes' |:."
