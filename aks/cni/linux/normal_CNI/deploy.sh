set -x
. ./params.sh

## Create Resource Group
az group create --name $RESOURCE_GROUP --location $REGION

## Dedicated virtual network with AKS subnet
az network vnet create \
    --resource-group $RESOURCE_GROUP \
    --name $VNET_NAME \
    --location $REGION \
    --address-prefixes $VNET_PREFIXE \
    --subnet-name $SUBNET_NAME \
    --subnet-prefix $SUBNET_PREFIXE

## Get VnetID
VNETID=$(az network vnet show -g $RESOURCE_GROUP --name $VNET_NAME --query id -o tsv)

## Get Subnet ID
SUBNETID=$(az network vnet subnet show -g $RESOURCE_GROUP --vnet-name $VNET_NAME --name $SUBNET_NAME --query id -o tsv)

## Create AKS Cluster
if [ $PRIVATE_CLUSTER == true ]
then
  echo '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
  echo "Creating AKS Private Cluster with Monitoring Enabled"
  echo '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
  az aks create -g $RESOURCE_GROUP -n $AKS_NAME -l $REGION \
    --node-count 1 \
    --generate-ssh-keys \
    --network-plugin $NETWORK_PLUGIN \
    --vnet-subnet-id $SUBNETID \
    --kubernetes-version $K8S_VERSION \
    --service-cidr $SERVICE_CIDR \
    --dns-service-ip $DNS_SERVICE_IP \
    --node-count $NODE_COUNT \
    --enable-addons monitoring \
    --enable-private-cluster
else
  echo '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
  echo "Creating AKS Public Cluster with Monitoring Enabled"
  echo '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
  az aks create -g $RESOURCE_GROUP -n $AKS_NAME -l $REGION \
    --node-count 1 \
    --generate-ssh-keys \
    --network-plugin $NETWORK_PLUGIN \
    --vnet-subnet-id $SUBNETID \
    --service-cidr $SERVICE_CIDR \
    --dns-service-ip $DNS_SERVICE_IP \
    --node-count $NODE_COUNT \
    --enable-addons monitoring \
    --kubernetes-version $K8S_VERSION
fi

## Add User Node Pool
if [ $AKS_HAS_2ND_NODEPOOL == true ]
then
  ## Add User nodepooll
  echo 'Add Node pool type User'
  az aks nodepool add \
    --resource-group $RESOURCE_GROUP \
    --name usrnp \
    --cluster-name $AKS_NAME \
    --node-osdisk-type Ephemeral \
    --kubernetes-version $AKS_VERSION \
    --mode User \
    --node-count $AKS_USR_NP_NODE_COUNT
fi

## get-credentials
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME
