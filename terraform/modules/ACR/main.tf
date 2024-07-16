resource "azurerm_container_registry" "acr" {
  count               = var.create_acr ? 1 : 0
  name                = "${var.prefix}${random_string.random.result}acr"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  sku                 = "Standard"
  admin_enabled       = false
}