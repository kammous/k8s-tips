#!/bin/bash

set -euxo pipefail

kubectl delete deploy echo
kubectl delete svc echo
kubectl delete -f https://raw.githubusercontent.com/metallb/metallb/main/manifests/metallb.yaml
kubectl delete -f https://raw.githubusercontent.com/metallb/metallb/main/manifests/namespace.yaml


