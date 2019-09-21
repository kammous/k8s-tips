#!/bin/bash

set -e
set -x

kubectl delete deploy echo
kubectl delete svc echo
kubectl delete -f https://raw.githubusercontent.com/google/metallb/v0.8.1/manifests/metallb.yaml


