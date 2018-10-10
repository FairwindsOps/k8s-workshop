#! /usr/bin/env bash
#
# author:   lance@reactiveops.com
# date      09-Oct-18
#
# purpose: automation script from building EKS clusters in cloud9 console
# dependencies: requires instance profile with admin role
#

echo -n "Please enter a name for your cluster and press [ENTER]":
read CLUSTERID

ROLE_ARN=$(aws iam create-role \
              --role-name ${CLUSTERID} \
              --assume-role-policy-document file://eks-role-policy.json \
              --query Role.Arn \
              --output text)

while read LINE; do
    aws iam attach-role-policy \
      --policy-arn $LINE \
      --role-name ${CLUSTERID}
done < policies.txt

## Create VPC and Network Facilities
aws cloudformation create-stack \
  --stack-name ${CLUSTERID} \
  --template-body https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/amazon-eks-vpc-sample.yaml

aws cloudformation wait stack-create-complete --stack-name lance-demo

VPC_ID=$(aws cloudformation describe-stacks \
              --stack-name ${CLUSTERID} \
              --query Stacks[0].Outputs[*].OutputValue \
              --output text | tr '\t' '\n' | grep vpc)

SUBNET_ID=$(aws cloudformation describe-stacks \
              --stack-name $CLUSTERID \
              --query Stacks[0].Outputs[*].OutputValue \
              --output text | tr '\t' '\n' | grep subnet)

SG_ID=$(aws cloudformation describe-stacks \
              --stack-name $CLUSTERID \
              --query Stacks[0].Outputs[*].OutputValue \
              --output text | tr '\t' '\n' | grep sg)


## Create Cluster
aws eks create-cluster \
  --name "${CLUSTERID}" \
  --role-arn "${ROLE_ARN}" \
  --resources-vpc-config \
    subnetIds=${SUBNET_ID},securityGroupIds=${SG_ID}
