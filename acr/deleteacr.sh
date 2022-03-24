#!/bin/bash

set -x
. ./params.sh

echo "Delete ACR"
az acr delete --name $ACR_NAME --yes

echo "Delete Resource Group"
az group delete --name $RESOURCE_GROUP --yes