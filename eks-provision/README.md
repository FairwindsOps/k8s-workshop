# EKS 101
1. [Boilerplate](#environment-setup)
2. [AWS Role Provisioning](#AWS-Role-Provisioning)
3. [Cloudformation](#Cloudformation)
4. [AWS IAM Authenticator](#AWS-IAM-Authenticator)
5. [Create EKS Cluster](#Create-EKS-Cluster)
6. [Setup kubectl](#Setup-kubectl)
7. [(Optional) Destroy Cluster](#Destroy-Cluster)

## Environment Setup

### Source .eks-101 file
```
cat <<EOF > .eks-101
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export AWS_DEFAULT_REGION=
export CLUSTERID=
EOF

source .eks-101
```

### Setup aws cli in python virtualenv
```
$ pip install --user virtualenv
$ virtual env .
$ source bin/activate
```

## AWS Role Provisioning


### Create Role
```
aws iam create-role \
  --role-name ${CLUSTERID} \
  --assume-role-policy-document file://eks-role-policy.json 
```

### Attach Canned Policies
```
for i in $(cat policy.list); do
    aws iam attach-role-policy \
      --policy-arn $i \
      --role-name ${CLUSTERID}
done
```

## Cloudformation
```
aws iam create-role \
  --role-name ${CLUSTERID} \
  --assume-role-policy-document
```

## AWS IAM Authenticator

### Download
```
mkdir ${HOME}/bin
curl -o $HOME/bin/heptio-authenticator-aws \
  https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/bin/darwin/amd64/heptio-authenticator-aws && \
  chmod +x ${HOME}/bin/heptio-authenticator-aws
```

### Configure
```
export PATH=$PATH:$HOME/bin
```

## Create Cluster
```
aws eks create-cluster \
  --name ${CLUSTERID} \
  --role-arn arn:aws:iam::338430314199:role/${CLUSTERID} \ ## change this
  --resources-vpc-config \
    subnetIds=subnet-0697703a5cee1c763,subnet-0b05c599aa75267e8,subnet-07940df2f00a4b15b,securityGroupIds=sg-06eec9099dac1520d ## change this
```

## Setup kubectl
[kubectl install page](https://kubernetes.io/docs/tasks/tools/install-kubectl)

We'll just install the vendored binary

### Download
macOS
```
curl -LO \
  https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/amd64/kubectl
  -o ${HOME}/bin/kubectl && \
  chomd +x ${HOME}/bin/kubectl
```

Linux
```
curl -LO \
  https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
  -o ${HOME}/bin/kubectl && \
  chomd +x ${HOME}/bin/kubectl
```

### Configure
