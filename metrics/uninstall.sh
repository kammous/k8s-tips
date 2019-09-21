#!/bin/bash
set -e
set -x

cd metrics-server
kubectl delete -f deploy/1.8+/
