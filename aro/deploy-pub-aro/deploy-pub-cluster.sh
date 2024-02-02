#!/bin/bash
set -x
. ./params.sh

# Create Resource Group
az group create --name $RESOURCE_GROUP --location $REGION

# Create Vnet
az network vnet create --resource-group $RESOURCE_GROUP --name $VNET_NAME --address-prefixes 10.0.0.0/22

##Masters Subnet
az network vnet subnet create --resource-group $RESOURCE_GROUP --vnet-name $VNET_NAME --name $SUBNET_MASTER --address-prefixes 10.0.2.0/24 --service-endpoints Microsoft.ContainerRegistry

##Workers Subnet
az network vnet subnet create --resource-group $RESOURCE_GROUP --vnet-name $VNET_NAME --name $SUBNET_WORKER --address-prefixes 10.0.3.0/24 --service-endpoints Microsoft.ContainerRegistry

##Masters Subnet - Update - disable-private-link-service-network-policies
az network vnet subnet update --name $SUBNET_MASTER --resource-group $RESOURCE_GROUP --vnet-name $VNET_NAME --disable-private-link-service-network-policies true

# Create SP
az ad sp create-for-rbac --name $AROSPDisplayName > arospinfo.json
cat arospinfo.json | base64 -w0 > secretJSON.txt
AROSPID=`jq -r .appId arospinfo.json`
AROSPPass=`jq -r .password arospinfo.json`
AROSPTENANTID=`jq -r .tenant arospinfo.json`
secretJSON=`cat secretJSON.txt`

az aro create --resource-group $RESOURCE_GROUP \
    --name $ARO_NAME \
    --vnet $VNET_NAME \
    --master-subnet $SUBNET_MASTER \
    --worker-subnet $SUBNET_WORKER \
    --pull-secret $PULL_SECRET \
    --client-id $AROSPID \
    --client-secret $AROSPPass \
    --cluster-resource-group $MC_RESOURCE_GROUP

# # Created with debug
# az aro create --resource-group $RESOURCE_GROUP --name $ARO_NAME --vnet $VNET_NAME --master-subnet $SUBNET_MASTER --worker-subnet $SUBNET_WORKER --pull-secret @pull-secret.txt --client-id $AROSPID --client-secret $AROSPPass --cluster-resource-group $MC_RESOURCE_GROUP --debug