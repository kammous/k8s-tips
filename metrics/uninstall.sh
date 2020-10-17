#!/bin/bash
set -euxo pipefail

kubectl delete -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.7/components.yaml

