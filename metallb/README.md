# Install and configure MetalLB on KIND cluster
## Setup a k8s cluster with KIND

## Deploy and expose echo-server
```
kubectl run echo --image=inanimate/echo-server --replicas=3 --port=8080
kubectl expose deployment echo --type=LoadBalancer
kubectl get svc echo
```
## Install MetalLB
```
kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.8.1/manifests/metallb.yaml
```
Configure MetalLB with the appropriate IP range
```
docker network inspect bridge | grep -i subnet
kubectl apply -f metallb-cm.yaml
```
Use EXTERNAL-IP to invoke echo service 

```
kubectl get svc echo
curl http://172.17.255.1:8080
```
