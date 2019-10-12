#!/bin/bash

set -e
set -x

helm reset

kubectl -n kube-system delete serviceaccount tiller --ignore-not-found=true
kubectl delete clusterrolebinding tiller --ignore-not-found=true

#kubectl -n kube-system delete deploy tiller-deploy --ignore-not-found=true