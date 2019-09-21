#!/bin/bash

set -e
set -x

kubectl delete hpa php-apache
kubectl delete deploy php-apache
kubectl delete svc php-apache
kubectl delete deploy load-generator

