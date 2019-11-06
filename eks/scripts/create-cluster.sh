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
kubectl get nodes
