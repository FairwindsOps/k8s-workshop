#! /usr/bin/env bash
#
# adds dependencies to cloud9 instance for
# completing the ReactiveOps EKS 101 training
#

#- VARIABLES -#
ARCH="amd64"
KUBECTL_VERSION="v1.14.8"


#- PROCEDURAL -#

# install kubectl
mkdir -p ~/.kube

# Install kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
  && chmod +x ./kubectl \
  && mv ./kubectl /usr/local/bin/kubectl

# amazon-linux deps
yum install -y jq

# setup region
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
echo "export AWS_REGION=${AWS_REGION}" >> ~/.bash_profile
aws configure set default.region ${AWS_REGION}

# eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin/eksctl

# verify binaries
printf "\n"
printf "Kubectl Version:\t%s\n" "$(kubectl version --short --client)"
printf "Eksctl Version:\t%s\n" "$(eksctl version)"
