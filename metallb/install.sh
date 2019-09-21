#/bin/sh

set -e
set -x
# install echo-server app and expose it externally with a kubernetes Service LoadBalancer
kubectl run echo --image=inanimate/echo-server --replicas=3 --port=8080
kubectl expose deployment echo --type=LoadBalancer
kubectl get svc echo
# istall and configure MetalLB
kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.8.1/manifests/metallb.yaml
kubectl -n metallb-system wait --timeout=300s --for=condition=Ready pod --all

docker network inspect bridge | grep -i subnet
kubectl apply -f metallb-cm.yaml

sleep 2s

kubectl get svc echo
export IP=$(kubectl get svc echo -o=jsonpath='{$.status.loadBalancer.ingress[0].ip}')
curl http://${IP}:8080

