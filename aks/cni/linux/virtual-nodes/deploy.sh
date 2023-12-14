# Need to double check this because it's not working 
# The Virtual node is not deployed
#!/bin/bash
set -x
. ./params.sh

# Create a Resource Group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create Virtual Network
az network vnet create \
    --resource-group $RESOURCE_GROUP \
    --name $VNET_NAME \
    --address-prefixes 10.0.0.0/8 \
    --subnet-name $SUBNET_NAME \
    --subnet-prefix 10.240.0.0/16

# Create Subnet for Virtual Node
az network vnet subnet create \
    --resource-group $RESOURCE_GROUP \
    --vnet-name $VNET_NAME \
    --name $SUBNET_NAME_VN \
    --address-prefixes 10.241.0.0/16

# Get AKS subnet id
AKSSUBNETID=`az network vnet subnet show --resource-group $RESOURCE_GROUP --vnet-name $VNET_NAME --name $SUBNET_NAME --query id -o tsv`

# Create AKS Cluster
az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_NAME \
    --node-count 1 \
    --network-plugin azure \
    --vnet-subnet-id $AKSSUBNETID

# Enable Addon
az aks enable-addons \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_NAME \
    --addons virtual-node \
    --subnet-name $SUBNET_NAME_VN

# Get Credentials
az aks get-credentials \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_NAME

# Deploy pod in virtual node
kubectl apply -f virtual-node.yaml