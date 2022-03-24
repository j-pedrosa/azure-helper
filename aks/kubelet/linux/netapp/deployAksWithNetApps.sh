#!/bin/bash
set -x

RESOURCE_GROUP="netapp-tst-1"
REGION="westeurope"
AKS_NAME="netapp-tst-1-aks"
SUBNET_NAME="NetAppSubnet"
NETAPP_NAME="netapp-tst-account-1"
NETAPP_POOL="netapp-tst-pool-1"
VOLUME_SIZE_GiB=100                 # 100 GiB
VOLUME_NAME="vol1"
UNIQUE_FILE_PATH_2="vol2"           # Note that file path needs to be unique within all ANF Accounts
UNIQUE_FILE_PATH="vol1"             # Note that file path needs to be unique within all ANF Accounts
VOLUME_NAME_2="vol2"
SERVICE_LEVEL="Standard"

# Create Resource Group
az group create --name $RESOURCE_GROUP --location $REGION

# Create Basic AKS Cluster
az aks create --resource-group $RESOURCE_GROUP --name $AKS_NAME --node-count 1 --generate-ssh-keys #--node-vm-size "standard_dc2s_v2"

# Register Microsoft.NetApp
az provider register --namespace Microsoft.NetApp --wait

# Get Node Resource Group
NODE_RESOURCE_GROUP=$(az aks show --resource-group $RESOURCE_GROUP --name $AKS_NAME --query nodeResourceGroup -o tsv)
echo $RESOURCE_GROUP_NODE

# Create NetApp Account
az netappfiles account create \
    --resource-group $NODE_RESOURCE_GROUP \
    --location $REGION \
    --account-name $NETAPP_NAME

# Create NetApp pool
az netappfiles pool create \
    --resource-group $NODE_RESOURCE_GROUP \
    --location $REGION \
    --account-name $NETAPP_NAME \
    --pool-name $NETAPP_POOL \
    --size 4 \
    --service-level Standard

# Create Vnet ids
VNET_NAME=$(az network vnet list --resource-group $NODE_RESOURCE_GROUP --query [].name -o tsv)
VNET_ID=$(az network vnet show --resource-group $NODE_RESOURCE_GROUP --name $VNET_NAME --query "id" -o tsv)

# Create NetApp Subnet
az network vnet subnet create \
    --resource-group $NODE_RESOURCE_GROUP \
    --vnet-name $VNET_NAME \
    --name $SUBNET_NAME \
    --delegations "Microsoft.NetApp/volumes" \
    --address-prefixes 10.241.0.0/28

# Get NetApp Subnet ID
SUBNET_ID=$(az network vnet subnet show --resource-group $NODE_RESOURCE_GROUP --vnet-name $VNET_NAME --name $SUBNET_NAME --query "id" -o tsv)

# Create NetAPp volume
az netappfiles volume create \
    --resource-group $NODE_RESOURCE_GROUP \
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

# Create NetApp Volume with Standard Network Features
az netappfiles volume create \
    --resource-group $NODE_RESOURCE_GROUP \
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

# Get AKS Cluster credentials
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME

# Create PVs, PVCs and PODs
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-nfs-v1
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteMany
  mountOptions:
    - vers=3
  nfs:
    server: 10.241.0.4
    path: /vol1
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-nfs-v2
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteMany
  mountOptions:
    - vers=3
  nfs:
    server: 10.241.0.5
    path: /vol2
EOF

cat <<EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-nfs-v1
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: ""
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-nfs-v2
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: ""
  resources:
    requests:
      storage: 1Gi
EOF

cat <<EOF | kubectl create -f -
kind: Pod
apiVersion: v1
metadata:
  name: nginx-nfs-v1
spec:
  containers:
  - image: mcr.microsoft.com/oss/nginx/nginx:1.15.5-alpine
    name: nginx-nfs
    command:
    - "/bin/sh"
    - "-c"
    - while true; do echo $(date) >> /mnt/azure/outfile; sleep 1; done
    volumeMounts:
    - name: disk01
      mountPath: /mnt/azure
  volumes:
  - name: disk01
    persistentVolumeClaim:
      claimName: pvc-nfs-v1
---
kind: Pod
apiVersion: v1
metadata:
  name: nginx-nfs-v2
spec:
  containers:
  - image: mcr.microsoft.com/oss/nginx/nginx:1.15.5-alpine
    name: nginx-nfs
    command:
    - "/bin/sh"
    - "-c"
    - while true; do echo $(date) >> /mnt/azure/outfile; sleep 1; done
    volumeMounts:
    - name: disk01
      mountPath: /mnt/azure
  volumes:
  - name: disk01
    persistentVolumeClaim:
      claimName: pvc-nfs-v2
EOF