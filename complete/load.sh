#!/bin/bash

if [ -z $1 ]; then
    echo "You need to specify an address to target"
    exit 1
fi

command -v k6 >/dev/null 2>&1 || { echo >&2 "I require k6 but it's not installed.  Aborting."; exit 1; }

export TARGET=$1

k6 run load.js --vus=5 --duration=0 -q --max=100 &
sleep 10
clear
