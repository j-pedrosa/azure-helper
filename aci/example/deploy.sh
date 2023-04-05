#Variables
NAME="repo1"
RESOURCE_GROUP="aci-$NAME-rg"
REGION="westeurope"
ACI_NAME="aci-$NAME"

echo "Create Resource Group"
az group create --name $RESOURCE_GROUP --location $REGION

echo "Create ACI"
az container create \
    --resource-group $RESOURCE_GROUP \
    --name helloworld \
    --image mcr.microsoft.com/azuredocs/aci-helloworld:latest \
    --dns-name-label $ACI_NAME \
    --ports 80 \
    --cpu 1 \
    --memory 2