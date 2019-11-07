#!/bin/bash

command -v k6 >/dev/null 2>&1 || { echo >&2 "I require k6 but it's not installed.  Aborting."; exit 1; }

elb=$(kubectl get svc -n k8s-workshop | grep LoadBalancer | awk '{print $3}')

if [ -z "$elb" ]; then
    echo "Could not find a service to target in k8s-workshop!"
    exit 1
fi
echo $elb
export TARGET=$elb

k6 run load.js --vus=5 --duration=0 -q --max=100
