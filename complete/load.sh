#!/bin/bash

export TARGET=$1

wget https://github.com/loadimpact/k6/releases/download/v0.25.1/k6-v0.25.1-linux64.tar.gz
tar -zxvf k6-v0.25.1-linux64.tar.gz
mv k6-v0.25.1-linux64/k6 /usr/local/bin/k6

k6 run load.js
