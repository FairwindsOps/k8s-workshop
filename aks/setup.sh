#!/bin/bash

RESOURCE_GROUP="${1:-aks101}"
CLUSTER_NAME="${2:-aks101}"
LOCATION="${3:-eastus}"

# If the script is not sourced, then don't run it.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    printf "\nScript ${BASH_SOURCE[0]} needs to be sourced, not run directly!!\n${bold}Try running 'source ${BASH_SOURCE[0]}'\n\n${normal}"
    exit 1
fi

printf "Creating cluster $CLUSTER_NAME in $LOCATION in resource group $RESOURCE_GROUP\n\n"

az group create --name $RESOURCE_GROUP --location $LOCATION

az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --node-count 2 \
    --enable-addons monitoring \
    --generate-ssh-keys

az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME

cd
mkdir -p ~/clouddrive/bin
wget https://github.com/loadimpact/k6/releases/download/v0.25.1/k6-v0.25.1-linux64.tar.gz
tar -zxvf k6-v0.25.1-linux64.tar.gz
mv k6-v0.25.1-linux64/k6 ~/clouddrive/bin/k6
rm -rf k6-v0.25.1-linux64  k6-v0.25.1-linux64.tar.gz

export PATH=~/clouddrive/bin/:$PATH
cd ~/clouddrive/k8s-workshop
