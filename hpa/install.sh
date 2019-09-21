#!/bin/bash

set -e
set -x

kubectl run php-apache --image=k8s.gcr.io/hpa-example --requests=cpu=200m --limits=cpu=500m --expose --port=80
kubectl wait --timeout=300s --for=condition=available deploy php-apache

kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10


echo "while true; do wget -q -O- http://php-apache.default.svc.cluster.local; done"
kubectl run -i --tty load-generator --image=busybox /bin/sh

