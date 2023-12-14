RESOURCE_GROUP=base-kubenet
LOCATION=eastus2
AKS_NAME=$RESOURCE_GROUP-ask
K8S_VERSION="1.28.3"

# Create Resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create AKS kubenet
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_NAME \
  --kubernetes-version $K8S_VERSION

# get-credentials
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME

