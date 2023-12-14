#!/bin/bash
set -x
. ./params.sh

az group create --name $IDENTITY_RESOURCE_GROUP --location $LOCATION

#Create an identity
az identity create --resource-group $IDENTITY_RESOURCE_GROUP --name $IDENTITY_NAME
IDENTITY_CLIENT_ID="$(az identity show -g $IDENTITY_RESOURCE_GROUP -n $IDENTITY_NAME --query clientId -otsv)"
IDENTITY_RESOURCE_ID="$(az identity show -g $IDENTITY_RESOURCE_GROUP -n $IDENTITY_NAME --query id -otsv)"


#Assign permissions for the managed identity
# Obtain the name of the resource group containing the Virtual Machine Scale set of your AKS cluster, commonly called the node resource group
NODE_GROUP=$(az aks show -g $RESOURCE_GROUP -n $AKS_NAME --query nodeResourceGroup -o tsv)

# Obtain the id of the node resource group 
NODES_RESOURCE_ID=$(az group show -n $NODE_GROUP -o tsv --query "id")

# Create a role assignment granting your managed identity permissions on the node resource group
az role assignment create --role "Virtual Machine Contributor" --assignee "$IDENTITY_CLIENT_ID" --scope $NODES_RESOURCE_ID

#Create a pod identity
az aks pod-identity add --resource-group $RESOURCE_GROUP --cluster-name $AKS_NAME --namespace $POD_IDENTITY_NAMESPACE  --name $POD_IDENTITY_NAME --identity-resource-id $IDENTITY_RESOURCE_ID


kubectl get azureidentity -n $POD_IDENTITY_NAMESPACE
kubectl get azureidentitybinding -n $POD_IDENTITY_NAMESPACE

echo "POD_IDENTITY_NAME: $POD_IDENTITY_NAME"
echo "IDENTITY_CLIENT_ID: $IDENTITY_CLIENT_ID"
echo "IDENTITY_RESOURCE_GROUP: $IDENTITY_RESOURCE_GROUP"


#Manually edit the yaml file and deploy the yaml file
# kubectl apply -f demo.yaml --namespace $POD_IDENTITY_NAMESPACE
# kubectl logs demo --follow --namespace $POD_IDENTITY_NAMESPACE