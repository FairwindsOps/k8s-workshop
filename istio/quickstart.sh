#!/bin/bash
# set -x
set -e

# quickstart.sh
# Create cluster and install istio and helm to prepare for the k8s workshop walk through

KUBERNETES_VERSION="1.9.7-gke.1"
GCP_ZONE="us-west1-b"
NETWORK="default"
APP_NAMESPACE="bookinfo"
CLUSTER_NAME="istio-demo-$(date '+%s')"
export ISTIO_VERSION="0.7.1"

cd $HOME

# Create cluster
gcloud beta container \
    --project $GOOGLE_CLOUD_PROJECT \
    clusters create $CLUSTER_NAME \
    --zone $GCP_ZONE \
    --no-enable-basic-auth \
    --enable-network-policy \
    --cluster-version $KUBERNETES_VERSION \
    --machine-type "n1-standard-1" \
    --image-type "COS" \
    --disk-size "100" \
    --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
    --num-nodes "3" \
    --network $NETWORK \
    --enable-cloud-logging \
    --enable-cloud-monitoring \
    --subnetwork $NETWORK \
    --enable-autoscaling \
    --min-nodes "3" \
    --max-nodes "6" \
    --addons HorizontalPodAutoscaling,HttpLoadBalancing \
    --enable-autorepair

# Configure kubectl to connect to this cluster
gcloud container clusters get-credentials $CLUSTER_NAME --zone $GCP_ZONE --project $GOOGLE_CLOUD_PROJECT

# Add role to your user
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value core/account)

# Install Istio in cloudshell
curl -L https://git.io/getLatestIstio | sh -

# Install Istio into cluster
kubectl apply -f istio-$ISTIO_VERSION/install/kubernetes/istio-auth.yaml

# Install Sidecar Injector
istio-$ISTIO_VERSION/install/kubernetes/webhook-create-signed-cert.sh \
    --service istio-sidecar-injector \
    --namespace istio-system \
    --secret sidecar-injector-certs

kubectl apply -f istio-$ISTIO_VERSION/install/kubernetes/istio-sidecar-injector-configmap-debug.yaml

cat istio-$ISTIO_VERSION/install/kubernetes/istio-sidecar-injector.yaml | \
     istio-$ISTIO_VERSION/install/kubernetes/webhook-patch-ca-bundle.sh > \
     istio-$ISTIO_VERSION/install/kubernetes/istio-sidecar-injector-with-ca-bundle.yaml

kubectl apply -f istio-$ISTIO_VERSION/install/kubernetes/istio-sidecar-injector-with-ca-bundle.yaml

# Label namespace so the injection works
kubectl create namespace $APP_NAMESPACE
kubectl label namespace $APP_NAMESPACE istio-injection=enabled

# Set $APP_NAMESPACE to current context
kubectl config set-context $(kubectl config current-context) --namespace $APP_NAMESPACE

# Deploy Bookinfo App
kubectl apply -f istio-$ISTIO_VERSION/samples/bookinfo/kube/bookinfo.yaml --namespace $APP_NAMESPACE
