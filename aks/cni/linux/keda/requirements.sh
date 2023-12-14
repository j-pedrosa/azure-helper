#https://learn.microsoft.com/en-us/azure/aks/keda-deploy-add-on-cli#install-the-aks-preview-azure-cli-extension
# Install the aks-preview Azure CLI extension
az extension add --name aks-preview
az extension update --name aks-preview

#https://learn.microsoft.com/en-us/azure/aks/keda-deploy-add-on-cli#register-the-aks-kedapreview-feature-flag
# Register the AKS-KedaPreview feature flag
az feature register --namespace "Microsoft.ContainerService" --name "AKS-KedaPreview"
az provider register --namespace Microsoft.ContainerService