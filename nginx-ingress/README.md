# Helm chart based setup
## Install
```
./install-lb.sh
```
## Uninstall
```
./uninstall.sh
```
# Manifest based setup
## Install
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/baremetal/deploy.yaml
```
## Uninstall
```
kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/baremetal/deploy.yaml
```
