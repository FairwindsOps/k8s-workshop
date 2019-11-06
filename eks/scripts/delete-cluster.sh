#! /usr/bin/env bash
# Destroy Cluster

#- VARIABLES -#
CLUSTERID=$1
DOCSDIR="docs"

if [ -z "${CLUSTERID}" ]; then
  echo -n "Please enter a name for your cluster and press [ENTER]":
  read CLUSTERID
fi

### Destroy worker-nodes stack
aws cloudformation delete-stack \
  --stack-name ${CLUSTERID}-workers

### Delete ec2 key pair
aws ec2 delete-key-pair \
  --key-name ${CLUSTERID}

### Delete EKS Cluster
aws eks delete-cluster \
  --name ${CLUSTERID}

### Delete VPC stack
aws cloudformation delete-stack \
  --stack-name ${CLUSTERID}

### Delete role
while read LINE; do
  aws iam detach-role-policy \
    --role-name ${CLUSTERID}-masters \
    --policy-arn $LINE
done < ${DOCSDIR}/policies.txt

aws iam delete-role \
  --role-name ${CLUSTERID}-masters
