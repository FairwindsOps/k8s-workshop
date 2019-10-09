#!/bin/bash

RESOURCE_GROUP="${1:-aks101}"
CLUSTER_NAME="${2:-aks101}"
LOCATION="${3:-eastus}"

printf "Destroying $CLUSTER_NAME in $LOCATION in resource group $RESOURCE_GROUP\n\n"

az group delete --name $RESOURCE_GROUP
