#!/bin/bash

set -euxo pipefail

kubectl apply -f  https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta4/aio/deploy/recommended.yaml
kubectl -n kubernetes-dashboard wait --timeout=300s --for=condition=available deploy --all
kubectl apply -f dashboard-adminuser.yml
kubectl apply -f admin-role-binding.yml
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}') 

echo "Use token above to login to kubernetes dahsboard\n"
echo "http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
