#!/bin/bash

set -e
set -x

RELEASE_NAME="nginx"
NS="nginx-ingress"

helm repo update

helm install stable/nginx-ingress --namespace $NS --name $RELEASE_NAME \
--set controller.kind=DaemonSet \
--set controller.externalTrafficPolicy="Local"

kubectl -n $NS wait --timeout=120s --for=condition=Ready po --all
