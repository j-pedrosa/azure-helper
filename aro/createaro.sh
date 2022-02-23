LOCATION=westeurope                                 # the region
SUBSCRIPTION=""                                     # the subscription id
RESOURCEGROUP=aro-rg                                # the name of the resource group where you want to create your cluster
CLUSTER=arocluster                                  # the name of your cluster

# az vm list-usage -l $LOCATION \
# --query "[?contains(name.value, 'standardDSv3Family')]" \
# -o table

# az account set --subscription $SUBSCRIPTION
# az provider register -n Microsoft.RedHatOpenShift --wait
# az provider register -n Microsoft.Compute --wait
# az provider register -n Microsoft.Storage --wait
# az provider register -n Microsoft.Authorization --wait

# az feature register --namespace Microsoft.RedHatOpenShift --name preview

az group create \
  --name $RESOURCEGROUP \
  --location $LOCATION

az network vnet create \
   --resource-group $RESOURCEGROUP \
   --name aro-vnet \
   --address-prefixes 10.0.0.0/22

az network vnet subnet create \
  --resource-group $RESOURCEGROUP \
  --vnet-name aro-vnet \
  --name master-subnet \
  --address-prefixes 10.0.0.0/23 \
  --service-endpoints Microsoft.ContainerRegistry

az network vnet subnet create \
  --resource-group $RESOURCEGROUP \
  --vnet-name aro-vnet \
  --name worker-subnet \
  --address-prefixes 10.0.2.0/23 \
  --service-endpoints Microsoft.ContainerRegistry

az network vnet subnet update \
  --name master-subnet \
  --resource-group $RESOURCEGROUP \
  --vnet-name aro-vnet \
  --disable-private-link-service-network-policies true

az aro create \
  --resource-group $RESOURCEGROUP \
  --name $CLUSTER \
  --vnet aro-vnet \
  --master-subnet master-subnet \
  --worker-subnet worker-subnet

az aro list-credentials \
  --name $CLUSTER \
  --resource-group $RESOURCEGROUP