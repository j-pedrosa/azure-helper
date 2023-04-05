#!/bin/bash

set -x
. ./params.sh

echo "Create Resource Group"
az group create --name $RESOURCE_GROUP --location $REGION

echo "Create an Azure file share"
# Create the storage account with the parameters
az storage account create \
    --resource-group $RESOURCE_GROUP \
    --name $ACI_PERS_STORAGE_ACCOUNT_NAME \
    --location $REGION \
    --sku Standard_LRS

# Create the file share
az storage share create \
  --name $ACI_PERS_SHARE_NAME \
  --account-name $ACI_PERS_STORAGE_ACCOUNT_NAME

echo "Create ACI"
az container create \
    --resource-group $RESOURCE_GROUP \
    --name hellofiles \
    --image mcr.microsoft.com/azuredocs/aci-hellofiles \
    --dns-name-label $ACI_NAME \
    --ports 80
