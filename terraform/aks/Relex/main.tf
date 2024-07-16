#######################Terraform seetings##################
terraform {
  required_version = ">= 1.7"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.84.0, < 4.0"
    }
  }
}

#####################Provider seetings#####################
provider "azurerm" {
  features {}
}

######################Variables############################
######################Global############################
variable "region" {
  type        = string
  default     = "West Europe"
  description = "Management resources region"
}

variable "prefix" {
  type        = string
  default     = "testing"
  description = "Naming Prefix"
}

variable "default_tags" {
  default = {
    created_by  = "Terraform"
    managed_by  = "Terraform"
    environment = "Testing"
  }
  description = "Default resource tags"
  type        = map(string)
}

######################AKS############################
variable "aks" {
  type = map(any)
  description = "Variables related to AKS"
  default = {
    k8s_version                   = "1.28.5"
    agents_pool_max_surge_default = "10%"
    agents_pool_max_surge_system  = null
    agents_pool_max_surge_user    = "20%"
    azure_policy_enabled          = true
  }
}

######################ACR############################
variable "create_acr" {
  type        = bool
  default     = true
  description = "Create or not the ACR (Detault: TRUE)"
}

variable "attach_acr" {
  type        = bool
  default     = true
  description = "Attach or not the ACR to AKS cluster by adding the needed Pull role (Detault: TRUE)"
}

###################Random string to generate unique names##
resource "random_string" "random" {
  length  = 5
  special = false
  upper   = false
}

###################Cluster Resource Group##################
resource "azurerm_resource_group" "aks_rg" {
  name     = "${var.prefix}-${random_string.random.result}-rg"
  location = var.region

  tags = merge(
    var.default_tags,
    {},
  )
}

###################AKS Cluster#############################
resource "azurerm_kubernetes_cluster" "aks" {
  name                 = "${var.prefix}-${random_string.random.result}-aks"
  location             = azurerm_resource_group.aks_rg.location
  resource_group_name  = azurerm_resource_group.aks_rg.name
  dns_prefix           = "${var.prefix}-${random_string.random.result}-aks"
  kubernetes_version   = var.aks.k8s_version
  azure_policy_enabled = var.aks.azure_policy_enabled

  default_node_pool {
    name                = "system"
    enable_auto_scaling = true
    max_count           = 4
    min_count           = 3
    vm_size             = "Standard_DS2_v2"

    upgrade_settings {
      max_surge = var.aks.agents_pool_max_surge_system == null ? var.aks.agents_pool_max_surge_default : var.aks.agents_pool_max_surge_system
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = merge(
    var.default_tags,
    {},
  )
}

###################User Node Pool##########################
resource "azurerm_kubernetes_cluster_node_pool" "user_nodepool" {
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_DS2_v2"
  mode                  = "User"
  enable_auto_scaling   = true
  max_count             = 3
  min_count             = 1
  upgrade_settings {
    max_surge = var.aks.agents_pool_max_surge_user == null ? var.aks.agents_pool_max_surge_default : var.aks.agents_pool_max_surge_user
  }

  tags = merge(
    var.default_tags,
    {
      nodepool = "user"
    },
  )
}

###################ACR#####################################
resource "azurerm_container_registry" "acr" {
  count               = var.create_acr ? 1 : 0
  name                = "${var.prefix}${random_string.random.result}acr"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  sku                 = "Standard"
  admin_enabled       = false
}

###################ACR attachment to AKS###################
# In thise case it's an ACR Pull role assigment to the cluster identity
resource "azurerm_role_assignment" "attach_acr" {
  count                = var.attach_acr ? 1 : 0
  scope                = azurerm_container_registry.acr[0].id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

###################kube_config output######################
output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}