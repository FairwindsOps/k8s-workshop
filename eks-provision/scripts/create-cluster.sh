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
INVENTORYDIR="inventory"
DOCSDIR="docs"
TEMPLATESDIR="templates"
KUBE_CONFIG=${HOME}/.kube/config
#AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)

#- functions -#
function get_cluster_status {
CLUSTERSTATUS=$(aws eks describe-cluster \
                  --name ${CLUSTERID} \
                  --query cluster.status \
                  --output text)
}

# setup region
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
echo "export AWS_REGION=${AWS_REGION}" >> ~/.bash_profile
aws configure set default.region ${AWS_REGION}

#- proecedural -#
if [ -z "${CLUSTERID}" ]; then
  echo -n "Please enter a name for your cluster and press [ENTER]":
  read CLUSTERID
fi

echo ""
echo "Creating $CLUSTERID-masters role for EKS master nodes"
aws iam get-role \
  --role-name ${CLUSTERID}-masters > /dev/null 2>&1

if [ "$?" -gt 0 ]; then
  aws iam create-role \
    --role-name ${CLUSTERID}-masters \
    --assume-role-policy-document file://${DOCSDIR}/eks-role-policy.json \
    --query Role.Arn \
    --output text > ${INVENTORYDIR}/role-arn.txt
fi

while read LINE; do
    aws iam attach-role-policy \
      --policy-arn $LINE \
      --role-name ${CLUSTERID}-masters
done < ${DOCSDIR}/policies.txt

## Create VPC and Network Facilities
echo "Creating VPC for EKS cluster"
aws cloudformation describe-stacks \
  --stack-name ${CLUSTERID} > /dev/null 2>&1

if [ "$?" -gt 0 ]; then
  aws cloudformation create-stack \
    --stack-name ${CLUSTERID} \
    --template-body https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/amazon-eks-vpc-sample.yaml
fi

aws cloudformation wait stack-create-complete --stack-name ${CLUSTERID}

echo ""
echo "Gathering ${CLUSTERID} cloudformation stack info for inventory ..."
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
aws eks describe-cluster \
  --name "${CLUSTERID}" > /dev/null 2>&1

if [ "$?" -gt 0 ]; then
  aws eks create-cluster \
    --name "${CLUSTERID}" \
    --role-arn "$( cat ${INVENTORYDIR}/role-arn.txt )" \
    --resources-vpc-config \
    subnetIds=$( cat ${INVENTORYDIR}/subnet-id.txt ),securityGroupIds=$( cat ${INVENTORYDIR}/sg-id.txt )

  # poll for cluster creations complete
  get_cluster_status
  while [ "${CLUSTERSTATUS}" == "CREATING" ]; do
      echo "The ${CLUSTERID} EKS managed control plane is still ${CLUSTERSTATUS}"
      sleep 5
      get_cluster_status
  done
  if [ "$CLUSTERSTATUS" == "ERROR" ]; then
      echo "The ${CLUSTERID} control plane failed to create"
      aws eks describe-cluster --name ${CLUSTERID} | jq .
      exit 1
  fi
fi

# configure kubectl access
# Set the cluster endpoint.
mkdir -p ~/.kube
cp ${TEMPLATESDIR}/.kubeconfig ~/.kube/config
i=$(aws eks describe-cluster \
      --name ${CLUSTERID} \
      --query cluster.endpoint \
      --output text);
sed -i -e s,ENDPOINT,$i,g ${KUBE_CONFIG}

#Set the cluster CA.
i=$(aws eks describe-cluster \
      --name ${CLUSTERID} \
      --query cluster.certificateAuthority.data \
      --output text);
sed -i -e s,CADATA,$i,g ${KUBE_CONFIG}

#Set the name of your cluster.
sed -i -e s,CLUSTERID,$CLUSTERID,g ${KUBE_CONFIG}

#Test connectivity
sleep 2
echo "Checking kuberentes namespaces"
kubectl get namespaces

aws ec2 create-key-pair \
  --key-name "${CLUSTERID}" \
  --query KeyMaterial \
  --output text > "${DOCSDIR}/${CLUSTERID}.pem"

echo "Creating kubernetes workers"
echo "Please be patient, this will take a few minutes"
echo ""
aws cloudformation create-stack \
  --stack-name "${CLUSTERID}-workers" \
  --template-body https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/amazon-eks-nodegroup.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameters \
      ParameterKey=ClusterName,ParameterValue="${CLUSTERID}" \
      ParameterKey=ClusterControlPlaneSecurityGroup,ParameterValue=$(cat ${INVENTORYDIR}/sg-id.txt) \
      ParameterKey=NodeGroupName,ParameterValue="${CLUSTERID}" \
      ParameterKey=NodeAutoScalingGroupMinSize,ParameterValue=1 \
      ParameterKey=NodeAutoScalingGroupMaxSize,ParameterValue=3 \
      ParameterKey=NodeInstanceType,ParameterValue=t2.medium \
      ParameterKey=NodeImageId,ParameterValue=$(cat "${INVENTORYDIR}/${AWS_REGION}.ami-id.txt") \
      ParameterKey=KeyName,ParameterValue="${CLUSTERID}" \
      ParameterKey=VpcId,ParameterValue=$(cat ${INVENTORYDIR}/vpc-id.txt) \
      ParameterKey=Subnets,ParameterValue=$(cat ${INVENTORYDIR}/subnet-id.txt | sed -e s#,#\\\\,#g)

aws cloudformation wait stack-create-complete --stack-name "${CLUSTERID}-workers"

aws cloudformation describe-stacks \
  --stack-name $CLUSTERID-workers \
  --query Stacks[0].Outputs[*].OutputValue \
  --output text > ${INVENTORYDIR}/node-role-arn.txt

i=$(cat ${INVENTORYDIR}/node-role-arn.txt);
cp ${INVENTORYDIR}/aws-auth-cm.yaml ${DOCSDIR}/
sed -i -e s,NODEROLEARN,$i,g ${DOCSDIR}/aws-auth-cm.yaml

kubectl apply -f ${DOCSDIR}/aws-auth-cm.yaml

sleep 60
echo "Checking for kubernetes workers"
kubectl get nodes
