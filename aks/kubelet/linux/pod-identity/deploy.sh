set -x
. ./params.sh

# Create Resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create AKS kubenet with OMS Add-on
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_NAME \
  --kubernetes-version $K8S_VERSION \
  --enable-pod-identity \
  --enable-pod-identity-with-kubenet

# get-credentials
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME

