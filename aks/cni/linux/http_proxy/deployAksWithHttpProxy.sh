#!/bin/bash
set -x

# Define Envrinoment Variables :
PREFIX="aks-http-proxy"
RG="${PREFIX}-rg"
LOC="westeurope"
PLUGIN=azure
AKSNAME="${PREFIX}"
VNET_NAME="${PREFIX}-vnet"
AKSSUBNET_NAME="aks-subnet"

# Create Resource Group
az group create --name $RG --location $LOC

# Dedicated virtual network with AKS subnet
az network vnet create \
    --resource-group $RG \
    --name $VNET_NAME \
    --location $LOC \
    --address-prefixes 10.42.0.0/16 \
    --subnet-name $AKSSUBNET_NAME \
    --subnet-prefix 10.42.1.0/24

SUBNETID=$(az network vnet subnet show -g $RG --vnet-name $VNET_NAME --name $AKSSUBNET_NAME --query id -o tsv)
az aks create -g $RG -n $AKSNAME -l $LOC \
  --node-count 3 --generate-ssh-keys \
  --network-plugin $PLUGIN \
  --vnet-subnet-id $SUBNETID \
  --http-proxy-config aks-proxy-config.json