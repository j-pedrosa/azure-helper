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

resource "azurerm_role_assignment" "attach_acr" {
  count                = var.attach_acr ? 1 : 0
  scope                = azurerm_container_registry.acr[0].id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}