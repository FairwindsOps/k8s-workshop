# EKS 101
1. [Create Cloud9 Environment](#create-cloud9-environment)
2. [Create Admin Role for Cloud9 Environment](#create-role)
3. [Attach Role to Cloud9 Environment](#attach-role-to-cloud9-environment)
4. [Turn Off Temorary Credentials in Cloud9](#turn-off-temporary-creds)
5. [Clone k8sworkshop Repo](#clone-k8sworkshop-repo)
6. [Create EKS Cluster](#create-eks-cluster)
7. [Delete EKS Cluster](#delete-eks-cluster)

## Create Cloud9 Environment
Click the link below to create a Cloud9 console environment

<a href="https://us-west-2.console.aws.amazon.com/cloud9/home?region=us-west-2" target="_blank">Cloud9</a>

## Create Role
Click the link below to create an Instance Profile to Attach to your Cloud9 Environment

[AWS IAM](https://console.aws.amazon.com/iam/home#/roles$new?step=review&commonUseCase=EC2%2BEC2&selectedUseCase=EC2&policies=arn:aws:iam::aws:policy%2FAdministratorAccess)

## Attach role to Cloud9 Environment
[Cloud9](https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#Instances:sort=desc:launchTime)

## Turn off temporary creds
* In Cloud9 Environment, go to preferences `⌘,`
* Go to *AWS SETTINGS*, then _Credentials_
* Toggle _AWS managed temporary credentials_ to off

## Install Utilites
* jq
```
wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
sudo mv jq-linux64 /usr/local/bin/jq
sudo chmod +x /usr/local/bin/jq
```

* kubectl
```
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
```

## Clone k8sworkshop Repo
Clone the k8sworkshpo repo and checkout the `eks` branch
```
sudo su -
git clone https://github.com/reactiveops/k8s-workshop.git
cd k8s-workshop
git checkout eks
```

## Create EKS cluster
```
cd eks-provision
./scripts/deps.sh
./scripts/create-cluster.sh
```

## Delete EKS Cluster
```
./scripts/delete-cluster.sh
```
