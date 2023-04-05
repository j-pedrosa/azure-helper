#!/bin/bash

set -x
. ./params.sh

echo "Create Resource Group"
az group create --name $RESOURCE_GROUP --location $REGION

echo "Create ACI"
az container create \
    --resource-group $RESOURCE_GROUP \
    --name hellofiles \
    --image mcr.microsoft.com/azuredocs/aci-hellofiles \
    --dns-name-label $ACI_NAME \
    --ports 80 \
    
echo "Get the web app's fully qualified domain name"
az container show --resource-group $RESOURCE_GROUP \
  --name hellofiles --query ipAddress.fqdn --output tsv