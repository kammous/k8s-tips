# Helm chart based
## Install
```
./install-lb.sh
```
## Uninstall
```
./uninstall.sh
```
# Manifest based install
## Install
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/baremetal/deploy.yaml
```
## Uninstall
```
kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/baremetal/deploy.yaml
```
