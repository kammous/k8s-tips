#!/bin/bash

set -e
set -x

HELM_VERSION="v2.16.1"
SCRIPT_FILE="get_helm.sh"
if [ ! -f "$SCRIPT_FILE" ]; then
  curl -LO https://git.io/get_helm.sh
fi
sudo chmod 700 $SCRIPT_FILE
./$SCRIPT_FILE --version $HELM_VERSION

echo "Install Tiller (the Helm server-side component) into your Kubernetes Cluster"
kubectl -n kube-system create serviceaccount tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account=tiller

echo "Wait until Tiller pod is Ready"
kubectl -n kube-system wait --timeout=300s --for=condition=Ready $(kubectl -n kube-system get pods -l app=helm -o=name)
