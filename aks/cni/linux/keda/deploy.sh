PREFIX="aks-keda"
RG="${PREFIX}-rg"
LOC="westeurope"
PLUGIN=azure
AKSNAME="${PREFIX}"
VNET_NAME="${PREFIX}-vnet"
AKSSUBNET_NAME="aks-subnet"
K8S_VERSION="1.24.6"

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

# Get VnetID
VNETID=$(az network vnet show -g $RG --name $VNET_NAME --query id -o tsv)

#Get Subnet ID
SUBNETID=$(az network vnet subnet show -g $RG --vnet-name $VNET_NAME --name $AKSSUBNET_NAME --query id -o tsv)

az aks create -g $RG -n $AKSNAME -l $LOC \
  --node-count 1 \
  --generate-ssh-keys \
  --network-plugin $PLUGIN \
  --vnet-subnet-id $SUBNETID \
  --kubernetes-version $K8S_VERSION \
  --enable-keda

# get-credentials
az aks get-credentials --resource-group $RG --name $AKSNAME