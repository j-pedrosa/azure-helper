#!/bin/bash

# Variables
RG="hpa-demo-rg"
AKS="hpa-demo"

echo "Resource group creation"
az group create --name $RG --location westeurope

echo "Create AKS with cluster autoscaler enabled"
az aks create \
  --resource-group $RG \
  --name $AKS \
  --node-count 1 \
  --vm-set-type VirtualMachineScaleSets \
  --load-balancer-sku standard \
  --enable-cluster-autoscaler \
  --min-count 1 \
  --max-count 3

echo "Config kubectl for the new cluster"
az aks get-credentials --resource-group $RG --name $AKS

echo "Apply stress.io deployment and hpa"
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: stress-io
  labels:
    app: stress-io
spec:
  replicas: 1
  selector:
    matchLabels:
      app: stress-io
  template:
    metadata:
      labels:
        app: stress-io
    spec:
      containers:
      - name: debian
        image: sturrent/debian:stress1
        resources:
          requests:  # minimum resources required
            cpu: 1000m
          limits: 
            cpu: 1020m  # maximum resources allocated
        command: ["/bin/bash"]
        args: ["-c", "while true; do stress --io 1024 --timeout 900s; done"]
---
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: stress-io-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: stress-io
  minReplicas: 1
  maxReplicas: 1000
  targetCPUUtilizationPercentage: 5
EOF


cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: internal-app
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-internal: "true"
spec:
  type: LoadBalancer
  ports:
  - port: 80
  selector:
    app: my-nginx
EOF