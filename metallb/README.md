# Install and configure MetalLB on KIND cluster

## Setup a k8s cluster with KIND
Refer to [KIND Quick Start](https://kind.sigs.k8s.io/docs/user/quick-start) for KIND installation steps.

## Deploy and expose echo-server
```
$ kubectl create deploy echo --image=inanimate/echo-server --replicas=3 --port=8080
$ kubectl expose deployment echo --type=LoadBalancer
$ kubectl get svc echo
```
## Install MetalLB
As per [MetalLB installation guide](https://metallb.universe.tf/installation/), you just need to run command below:
```shell
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/main/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/main/manifests/metallb.yaml
# On first install only
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
kubectl -n metallb-system wait --timeout=300s --for=condition=Ready pod --all
```
Determine subnet used by KIND nodes
```
$ docker network inspect bridge | grep -i subnet
                    "Subnet": "172.17.0.0/16",
```
Configure MetalLB with the appropriate IP range. Refer to [IP-Calculator](http://jodies.de/ipcalc?host=172.17.0.0&mask1=16&mask2=) for subnet calculation.
```
$ kubectl apply -f metallb-cm.yaml
```
Use EXTERNAL-IP to invoke echo service 

```
$ kubectl get svc echo
$ curl http://172.17.255.1:8080
```
