resource "azurerm_resource_group" "acr_rg" {
  name     = var.acr_rg
  location = var.region
}

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.acr_rg.name
  location            = azurerm_resource_group.acr_rg.location
  sku                 = var.acr_sku
  admin_enabled       = var.acr_admin_enabled
}