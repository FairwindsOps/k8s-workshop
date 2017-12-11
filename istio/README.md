

# ReactiveOps Kubernetes Istio Workbook
This assumes you already have a working Kubernetes cluster

## Download and install Istio
```
export ISTIO_VERSION=0.3.0
curl -L https://git.io/getLatestIstio | sh -
export PATH=$PWD/istio-$ISTIO_VERSION/bin:$PATH
```

## Once you have created your cluster, you need to make your user a cluster admin
```
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value core/account)
```

## Configure Istio with TLS in your cluster
```
cd istio-0.3.0/
kubectl apply -f install/kubernetes/istio-auth.yaml
```
### Verify TLS
```
kubectl get configmap istio -o yaml -n istio-system | grep authPolicy | head -1
```
Get product Pod name
```
kubectl exec -it <productpage_pod> -c istio-proxy /bin/bash
```
In the container: 
```
curl https://details:9080/details/0 -v --key /etc/certs/key.pem --cert /etc/certs/cert-chain.pem --cacert /etc/certs/root-cert.pem -k
```


## Deploy Book Info Application
```
kubectl apply -f <(istioctl kube-inject -f samples/bookinfo/kube/bookinfo.yaml)
```
Find LB ip address
```
kubectl get services --all-namespaces
```
### Route all traffic to V1 of Book Info Reviews Service

```
kubectl apply -f samples/bookinfo/kube/route-rule-all-v1.yaml
```
https://github.com/istio/istio/blob/master/samples/bookinfo/kube/route-rule-all-v1.yaml

### Content based routing for V2 of the Book Info Reviews Service
```
kubectl apply -f samples/bookinfo/kube/route-rule-reviews-test-v2.yaml
```
https://github.com/istio/istio/blob/master/samples/bookinfo/kube/route-rule-reviews-test-v2.yaml

### AB Test V2 and V3 of Book Info Reviews Service
```
kubectl apply -f samples/bookinfo/kube/route-rule-reviews-v2-v3.yaml
```
https://github.com/istio/istio/blob/master/samples/bookinfo/kube/route-rule-reviews-v2-v3.yaml

## Mixer Telemetry and Prometheus

Add Prometheus
```
kubectl apply -f install/kubernetes/addons/prometheus.yaml
```

Add Telemetry spec for Mixer and Prometheus
```
kubectl apply -f https://raw.githubusercontent.com/reactiveops/k8s-workshop/master/istio/new_telemetry.yaml 
```
View Prometheus Dashboard
```
kubectl -n istio-system port-forward prometheus-168775884-1xvvx 808
0:9090
```

## Istio Dashboard in Grafana

```
kubectl apply -f install/kubernetes/addons/grafana.yaml
```
```
kubectl -n istio-system port-forward grafana-2369932619-qmhlt 8080:3000
```

# Istio Docs: 
https://istio.io/docs/welcome/

# More resource: 
https://github.com/retroryan/istio-workshop

