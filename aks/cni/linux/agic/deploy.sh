#!/bin/bash
set -x
. ./params.sh

#Create Resource Group
az group create --name $RESOURCE_GROUP \
    --location $LOCATION

#Create AKS in Greenfield method
az aks create -n $AKS_NAME \
    -g $RESOURCE_GROUP \
    --network-plugin azure \
    --enable-managed-identity \
    -a ingress-appgw \
    --appgw-name $AGIC_NAME \
    --appgw-subnet-cidr "10.2.0.0/16" \
    --generate-ssh-keys

#Get Credentials
az aks get-credentials -n $AKS_NAME \
    -g $RESOURCE_GROUP

#Deploy pod and ingress
kubectl apply -f https://raw.githubusercontent.com/Azure/application-gateway-kubernetes-ingress/master/docs/examples/aspnetapp.yaml

#Get ingress
kubectl get ingress

#Delete infra
#az group delete --name $RESOURCE_GROUP