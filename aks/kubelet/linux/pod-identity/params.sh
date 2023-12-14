RESOURCE_GROUP=pod-identity-kubenet
LOCATION=westeurope
AKS_NAME=$RESOURCE_GROUP-aks
K8S_VERSION="1.25.5"

# Pod-Identity
IDENTITY_RESOURCE_GROUP="myIdentityResourceGroup"
IDENTITY_NAME="application-identity"
POD_IDENTITY_NAME="my-pod-identity"
POD_IDENTITY_NAMESPACE="my-app"