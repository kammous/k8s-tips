#!/bin/bash
set -euxo pipefail

cd metrics-server
kubectl delete -f deploy/1.8+/
