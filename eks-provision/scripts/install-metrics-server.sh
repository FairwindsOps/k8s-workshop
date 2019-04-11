#! /usr/bin/env bash

helm upgrade metrics-server stable/metrics-server --install --version 2.0.4 --namespace kube-system
