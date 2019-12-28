#!/bin/bash

set -euxo pipefail

RELEASE_NAME="nginx"
NS="nginx-ingress"

helm repo update

helm install stable/nginx-ingress --namespace $NS --name $RELEASE_NAME \
--set controller.kind=DaemonSet \
--set controller.service.type="ClusterIP" \
--set controller.externalTrafficPolicy="Local" \
--set controller.daemonset.useHostPort=true

kubectl -n $NS wait --timeout=120s --for=condition=Ready po --all
