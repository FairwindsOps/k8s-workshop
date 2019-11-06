#! /usr/bin/env bash
#
# author:   lance@reactiveops.com
# date      09-Oct-18
#
# purpose: automation script from building EKS clusters in cloud9 console
# dependencies: requires instance profile with admin role
#

#- variables -#
CLUSTERID=$1

#- functions -#
function get_cluster_status {
CLUSTERSTATUS=$(aws eks describe-cluster \
                  --name ${CLUSTERID} \
                  --query cluster.status \
                  --output text)
}


#- proecedural -#
if [ -z "${CLUSTERID}" ]; then
  echo -n "Please enter a name for your cluster and press [ENTER]":
  read CLUSTERID
fi

eksctl create cluster --name $CLUSTERID

#Install metrics-server
DOWNLOAD_URL=$(curl --silent "https://api.github.com/repos/kubernetes-sigs/metrics-server/releases/latest" | jq -r .tarball_url)
DOWNLOAD_VERSION=$(grep -o '[^/v]*$' <<< $DOWNLOAD_URL)
curl -Ls $DOWNLOAD_URL -o metrics-server-$DOWNLOAD_VERSION.tar.gz
mkdir metrics-server-$DOWNLOAD_VERSION
tar -xzf metrics-server-$DOWNLOAD_VERSION.tar.gz --directory metrics-server-$DOWNLOAD_VERSION --strip-components 1
kubectl apply -f metrics-server-$DOWNLOAD_VERSION/deploy/1.8+/

kubectl get nodes
