# Install and configure MetalLB on KIND cluster

## Setup a k8s cluster with KIND
Refer to [KIND Quick Start](https://kind.sigs.k8s.io/docs/user/quick-start) for KIND installation steps.

## Deploy and expose echo-server
```
$ kubectl run echo --image=inanimate/echo-server --replicas=3 --port=8080
$ kubectl expose deployment echo --type=LoadBalancer
$ kubectl get svc echo
```
## Install MetalLB
As per [MetalLB installation guide](https://metallb.universe.tf/installation/), you just need to run command below:
```
$ kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.8.1/manifests/metallb.yaml
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
