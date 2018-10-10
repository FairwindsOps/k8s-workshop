#! /usr/bin/env bash
#
# author:   lance@reactiveops.com
# date      09-Oct-18
#
# purpose: automation script from building EKS clusters in cloud9 console
# dependencies: requires instance profile with admin role
#

#- variables -#
CLUSTERID=
INVENTORYDIR="inventory"
DOCSDIR="docs"

#- functions -#
function get_cluster_status {
CLUSTERSTATUS=$(aws eks describe-cluster \
                  --name ${CLUSTERID} \
                  --query cluster.status)
}


#- proecedural -#
echo -n "Please enter a name for your cluster and press [ENTER]":
read CLUSTERID

aws iam create-role \
  --role-name ${CLUSTERID} \
  --assume-role-policy-document file://eks-role-policy.json \
  --query Role.Arn \
  --output text > ${INVENTORYDIR}/role-arn.txt

while read LINE; do
    aws iam attach-role-policy \
      --policy-arn $LINE \
      --role-name ${CLUSTERID}
done < ${DOCSDIR}/policies.txt

## Create VPC and Network Facilities
aws cloudformation create-stack \
  --stack-name ${CLUSTERID} \
  --template-body https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/amazon-eks-vpc-sample.yaml

aws cloudformation wait stack-create-complete --stack-name ${CLUSTERID}

aws cloudformation describe-stacks \
  --stack-name ${CLUSTERID} \
  --query Stacks[0].Outputs[*].OutputValue \
  --output text | tr '\t' '\n' | grep vpc > ${INVENTORYDIR}/vpc-id.txt

aws cloudformation describe-stacks \
  --stack-name $CLUSTERID \
  --query Stacks[0].Outputs[*].OutputValue \
  --output text | tr '\t' '\n' | grep subnet > ${INVENTORYDIR}/subnet-id.txt

aws cloudformation describe-stacks \
  --stack-name $CLUSTERID \
  --query Stacks[0].Outputs[*].OutputValue \
  --output text | tr '\t' '\n' | grep sg > ${INVENTORYDIR}/sg-id.txt


## Create Cluster
aws eks create-cluster \
  --name "${CLUSTERID}" \
  --role-arn "$( cat ${INVENTORYDIR}/role-arn.txt )" \
  --resources-vpc-config \
  subnetIds=$( cat ${INVENTORYDIR}/subnet-id.txt ),securityGroupIds=$( cat ${INVENTORYDIR}/sg-id.txt )

# poll for cluster creations complete
get_cluster_status
while [ "${CLUSTERSTATUS}" == "CREATING" ]; do
    echo -n "The ${CLUSTERID} control plane is still ${CLUSTERSTATUS}"
    sleep 5
    get_cluster_status
done
if [ "$CLUSTERSTATUS" == "ERROR" ]; then
    echo "The ${CLUSTERID} control plane failed to create"
    aws eks describe-cluster --name ${CLUSTERID} | jq .
    exit 1
fi

# configure kubect access
# Set the cluster endpoint.
i=$(aws eks describe-cluster \
      --name ${CLUSTERID} \
      --query cluster.endpoint \
      --output text);
sed -i -e s,ENDPOINT,$i,g ${DOCSDIR}/.kubeconfig

#Set the cluster CA.
i=$(aws eks describe-cluster \
      --name ${CLUSTERID} \
      --query cluster.certificateAuthority.data \
      --output text);
sed -i -e s,CADATA,$i,g ${DOCSDIR}/.kubeconfig

#Set the name of your cluster.
sed -i -e s,CLUSTERID,$CLUSTERID,g ${DOCSDIR}/.kubeconfig

cp ${DOCSDIR}/.kubeconfig ~/.kube/config

#Test connectivity
kubectl get ns
