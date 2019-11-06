#! /usr/bin/env bash
# Destroy Cluster

#- VARIABLES -#
CLUSTERID=$1

if [ -z "${CLUSTERID}" ]; then
  echo -n "Please enter a name for your cluster and press [ENTER]":
  read CLUSTERID
fi

eksctl delete cluster --name $CLUSTERID
