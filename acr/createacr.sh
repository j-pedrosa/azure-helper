#!/bin/bash

set -x
. ./params.sh

echo "Create Resource Group"
az group create --name $RESOURCE_GROUP --location $REGION

echo "Create ACR"
az acr create --resource-group $RESOURCE_GROUP \
    --name $ACR_NAME --sku $ACR_SKU
