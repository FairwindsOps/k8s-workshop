#! /usr/bin/env bash

curl -o /tmp/helm-v2.13.1-linux-amd64.tar.gz https://storage.googleapis.com/kubernetes-helm/helm-v2.13.1-linux-amd64.tar.gz
tar -xvf /tmp/helm-v2.13.1-linux-amd64.tar.gz -C /tmp
mv /tmp/linux-amd64/helm /usr/local/bin/helm
chmod u+x /usr/local/bin/helm

helm version

kubectl -n "${TILLER_NAMESPACE:-kube-system}" create sa tiller \
  --dry-run -o yaml --save-config | kubectl apply -f -
  
kubectl create clusterrolebinding tiller \
  --clusterrole cluster-admin \
  --serviceaccount="${TILLER_NAMESPACE:-kube-system}":tiller \
  --serviceaccount=kube-system:tiller \
  -o yaml --dry-run | kubectl -n "${TILLER_NAMESPACE:-kube-system}" apply -f -
  
helm init --upgrade --service-account tiller
