# EKS 101
1. [Environment Setup](#environment-setup)
2. [AWS Role Provisioning](#aws-role-provisioning)
3. [Cloudformation](#create-vpc-and-networ-facilities)
4. [AWS IAM Authenticator](#aws-iam-authenticator)
5. [Create EKS Cluster](#create-eks-cluster)
6. [Setup kubectl](#setup-kubectl)
7. [Create Worker Nodes](#create-worker-nodes)
8. [(Optional) Destroy Cluster](#destroy-cluster)

## Environment Setup
Source some environment variables to aws api access and an id for the resources
we will create.

### Source .eks-101 file
```
cat <<EOF > .eks-101
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export AWS_DEFAULT_REGION=
export CLUSTERID=

export KUBECONFIG=$PWD/.kubeconfig
export PATH=$PATH:$HOME/bin
EOF

source .eks-101
```

### Setup aws cli in python virtualenv
```
pip install --user virtualenv
virtualenv .
source bin/activate
pip install -U awscli
```

## AWS Role Provisioning


### Create Role
Create a role to be assumed by the kubernetes masters and nodes that will them to
talk to eachother.
```
aws iam create-role \
  --role-name ${CLUSTERID} \
  --assume-role-policy-document file://eks-role-policy.json \
  --query Role.Arn \
  --output text > role-arn.txt
```

### Attach Canned Policies
Attach the `AmazonEKSClusterPolicy` and `AmazonEKSServicePolicy` to the new role.
```
while read LINE; do
    aws iam attach-role-policy \
      --policy-arn $LINE \
      --role-name ${CLUSTERID}
done < policies.txt
```

## Create VPC and Network Facilities
An AWS managed cloudformation template is the simplest way to create the VPC,
subnets, routes and internet gateway required to support Kubernetes nodes.
```
aws cloudformation create-stack \
  --stack-name ${CLUSTERID} \
  --template-body https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/amazon-eks-vpc-sample.yaml
```

We will need to stash VPC, subnet and security group id values
```
aws cloudformation describe-stacks \
  --stack-name $CLUSTERID \
  --query Stacks[0].Outputs[*].OutputValue \
  --output text | tr '\t' '\n' | grep vpc > vpc-id.txt
```

```
aws cloudformation describe-stacks \
  --stack-name $CLUSTERID \
  --query Stacks[0].Outputs[*].OutputValue \
  --output text | tr '\t' '\n' | grep subnet > subnet-id.txt
```

```
aws cloudformation describe-stacks \
  --stack-name $CLUSTERID \
  --query Stacks[0].Outputs[*].OutputValue \
  --output text | tr '\t' '\n' | grep sg > sg-id.txt
```

## Create Cluster
Create eks cluster
```
aws eks create-cluster \
  --name ${CLUSTERID} \
  --role-arn $(cat role-arn.txt) \
  --resources-vpc-config \
    subnetIds=$(cat subnet-id.txt),securityGroupIds=$(cat sg-id.txt)
```

Check cluster status
```
aws eks describe-cluster \
  --name ${CLUSTERID} \
  --query cluster.status
```

## AWS IAM Authenticator

### Download
macOS
```
mkdir ${HOME}/bin
curl -o $HOME/bin/heptio-authenticator-aws \
  https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/bin/darwin/amd64/heptio-authenticator-aws && \
  chmod +x ${HOME}/bin/heptio-authenticator-aws
```

Linux
```
mkdir ${HOME}/bin
  curl -o $HOME/bin/heptio-authenticator-aws \
  https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/linux/amd64/aws-iam-authenticator \
  chmod +x ${HOME}/bin/heptio-authenticator-aws
```

## Setup kubectl
Kubernetes offers packages for the cli via most package managers.  Instructions based
on your package manager can be at the link below.
[kubectl install page](https://kubernetes.io/docs/tasks/tools/install-kubectl)

For simplicity we will just install the vendored binary

### Download
macOS
```
curl \
  -o ${HOME}/bin/kubectl \
  https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/amd64/kubectl && \
  chomd +x ${HOME}/bin/kubectl
```

Linux
```
curl \
  -o ${HOME}/bin/kubectl \
  https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
  chmod +x ${HOME}/bin/kubectl
```

### Configure
To configure kubectl we will need to edit a config file with the endpoint and CA
for the cluster api along with local config for the heptio-iam-authenticator.

The following series of sed commands will customize a the provided `.kubeconfig`
file

Set the cluster endpoint.
```
i=$(aws eks describe-cluster \
      --name ${CLUSTERID} \
      --query cluster.endpoint \
      --output text);
sed -i -e s,ENDPOINT,$i,g .kubeconfig
```

Set the cluster CA.
```
i=$(aws eks describe-cluster \
      --name ${CLUSTERID} \
      --query cluster.certificateAuthority.data \
      --output text);
sed -i -e s,CADATA,$i,g .kubeconfig
```

Set the name of your cluster.
```
sed -i -e s,CLUSTERID,$CLUSTERID,g .kubeconfig
```

Test connectivity
```
kubectl get namespaces
```

## Create Worker Nodes
Again we will use an AWS managed Cloudformation template to create worker nodes
within the VPC we created earlier.

First create a RSA key pair to be used for ssh access to the worker nodes
```
aws ec2 create-key-pair \
  --key-name "${CLUSTERID}" \
  --query KeyMaterial \
  --output text > "${CLUSTERID}.pem"
```

```
aws cloudformation create-stack \
  --stack-name "${CLUSTERID}-workers" \
  --template-body https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/amazon-eks-nodegroup.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameters \
      ParameterKey=ClusterName,ParameterValue="${CLUSTERID}" \
      ParameterKey=ClusterControlPlaneSecurityGroup,ParameterValue=$(cat sg-id.txt) \
      ParameterKey=NodeGroupName,ParameterValue="${CLUSTERID}" \
      ParameterKey=NodeAutoScalingGroupMinSize,ParameterValue=1 \
      ParameterKey=NodeAutoScalingGroupMaxSize,ParameterValue=3 \
      ParameterKey=NodeInstanceType,ParameterValue=t2.medium \
      ParameterKey=NodeImageId,ParameterValue=$(cat "${AWS_DEFAULT_REGION}.ami-id.txt") \
      ParameterKey=KeyName,ParameterValue="${CLUSTERID}" \
      ParameterKey=VpcId,ParameterValue=$(cat vpc-id.txt) \
      ParameterKey=Subnets,ParameterValue=$(cat subnet-id.txt | sed -e s#,#\\\\,#g) 
```

Monitor progress
```
aws cloudformation describe-stack-resources \
  --stack-name ${CLUSTERID}-workers
```

Once stack is complete we need to stash the arn for the nodes instance role
```
aws cloudformation describe-stacks \
  --stack-name $CLUSTERID-workers \
  --query Stacks[0].Outputs[*].OutputValue \
  --output text > node-role-arn.txt
```

... and modify the `aws-auth-cm.yaml` file with this value
```
i=$(cat node-role-arn.txt);
sed -i -e s,NODEROLEARN,$i,g aws-auth-cm.yaml
```

... and apply the configmap to kubernetes.  This will authorize incoming connections
form workers to masters
```
kubectl apply -f aws-auth-cm.yaml
```

Test to see if worker nodes are available in your cluster
```
kubectl get nodes
```

## Destroy Cluster

### Destroy worker-nodes stack
```
aws cloudformation delete-stack \
  --stack-name ${CLUSTERID}-workers
```

### Delete ec2 key pair
```
aws ec2 delete-key-pair \
  --key-name "${CLUSTERID}"
```

### Delete EKS Cluster
```
aws eks delete-cluster \
  --name ${CLUSTERID}
```

### Delete VPC stack
```
aws cloudformation delete-stack \
  --stack-name ${CLUSTERID}
```

### Delete role
Start by detaching the policies
```
while read LINE; do
  aws iam detach-role-policy \
    --role-name ${CLUSTERID} \
    --policy-arn $LINE
done < policies.txt
```

and then delete the role
```
aws iam delete-role \
  --role-name ${CLUSTERID}
```
