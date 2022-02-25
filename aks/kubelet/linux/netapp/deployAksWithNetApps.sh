#!/bin/bash

RG="netapp-tst-1"
REGION="westeurope"
AKS_NAME="netapp-tst-1"
SUBNET_NAME="NetAppSubnet"
NETAPP_NAME="netapp-tst-account-2"
NETAPP_POOL="netapp-tst-pool-2"
VOLUME_SIZE_GiB=100 # 100 GiB
VOLUME_NAME="vol1"
UNIQUE_FILE_PATH="vol1" # Note that file path needs to be unique within all ANF Accounts
SERVICE_LEVEL="Standard"

az group create --name $RG --location $REGION
az aks create --resource-group $RG --name $AKS_NAME --node-count 1 --generate-ssh-keys #--node-vm-size "standard_dc2s_v2"

az provider register --namespace Microsoft.NetApp --wait

RG_NODE=$(az aks show --resource-group $RG --name $AKS_NAME --query nodeResourceGroup -o tsv)
echo $RG_NODE

az netappfiles account create \
    --resource-group $RG_NODE \
    --location $REGION \
    --account-name $NETAPP_NAME

az netappfiles pool create \
    --resource-group $RG_NODE \
    --location $REGION \
    --account-name $NETAPP_NAME \
    --pool-name $NETAPP_POOL \
    --size 4 \
    --service-level Standard

VNET_NAME=$(az network vnet list --resource-group $RG_NODE --query [].name -o tsv)
VNET_ID=$(az network vnet show --resource-group $RG_NODE --name $VNET_NAME --query "id" -o tsv)
az network vnet subnet create \
    --resource-group $RG_NODE \
    --vnet-name $VNET_NAME \
    --name $SUBNET_NAME \
    --delegations "Microsoft.NetApp/volumes" \
    --address-prefixes 10.241.0.0/28

SUBNET_ID=$(az network vnet subnet show --resource-group $RG_NODE --vnet-name $VNET_NAME --name $SUBNET_NAME --query "id" -o tsv)

az netappfiles volume create \
    --resource-group $RG_NODE \
    --location $REGION \
    --account-name $NETAPP_NAME \
    --pool-name $NETAPP_POOL \
    --name $VOLUME_NAME \
    --service-level $SERVICE_LEVEL \
    --vnet $VNET_ID \
    --subnet $SUBNET_ID \
    --usage-threshold $VOLUME_SIZE_GiB \
    --file-path $UNIQUE_FILE_PATH \
    --protocol-types "NFSv3" \
    --rule-index 1 \
    --allowed-clients "0.0.0.0/0" \
    --unix-read-write "true" \
    --has-root-access "true"

# Enable 'ANFSDNAppliance' and 'AllowPoliciesOnBareMetal' feature (can take some minutes to be fully registered)
az feature registration create --name ANFSDNAppliance --namespace Microsoft.NetApp
az feature registration create --name AllowPoliciesOnBareMetal --namespace Microsoft.Network

# Check if the 'state' is set to 'Registered'
az feature registration show --name ANFSDNAppliance --provider-namespace Microsoft.NetApp
az feature registration show --name AllowPoliciesOnBareMetal --provider-namespace Microsoft.Network

VOLUME_NAME_2="vol2"
UNIQUE_FILE_PATH_2="vol2" # Note that file path needs to be unique within all ANF Accounts
az netappfiles volume create \
    --resource-group $RG_NODE \
    --location $REGION \
    --account-name $NETAPP_NAME \
    --pool-name $NETAPP_POOL \
    --name $VOLUME_NAME_2 \
    --service-level $SERVICE_LEVEL \
    --vnet $VNET_ID \
    --subnet $SUBNET_ID \
    --network-features "Standard" \
    --usage-threshold $VOLUME_SIZE_GiB \
    --file-path $UNIQUE_FILE_PATH_2 \
    --protocol-types "NFSv3" \
    --rule-index 1 \
    --allowed-clients "0.0.0.0/0" \
    --unix-read-write "true" \
    --has-root-access "true"
