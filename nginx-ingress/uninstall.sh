#!/bin/bash

set -euxo pipefail

RELEASE_NAME="nginx"
NS="nginx-ingress"

helm delete $RELEASE_NAME --purge
kubectl delete ns $NS --ignore-not-found
