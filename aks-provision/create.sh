#!/bin/bash

RESOURCE_GROUP="${1:-aks101}"
CLUSTER_NAME="${2:-aks101}"
LOCATION="${3:-eastus}"

printf "Creating cluster $CLUSTER_NAME in $LOCATION in resource group $RESOURCE_GROUP\n\n"

az group create --name $RESOURCE_GROUP --location $LOCATION

az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --node-count 2 \
    --enable-addons monitoring \
    --generate-ssh-keys

az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME
