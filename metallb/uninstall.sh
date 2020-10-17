#!/bin/bash

set -euxo pipefail

kubectl delete deploy echo
kubectl delete svc echo
kubectl delete -f https://raw.githubusercontent.com/metallb/metallb/main/manifes
ts/metallb.yaml
kubectl delete -f https://raw.githubusercontent.com/metallb/metallb/main/manifes
ts/namespace.yaml


