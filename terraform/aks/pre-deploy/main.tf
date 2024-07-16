resource "random_string" "random" {
    length = 5
    special = false
    upper   = false
}


resource "azurerm_resource_group" "rg_management" {
  name     = "${var.rg_prefix}-${random_string.random.result}"
  location = var.region

  tags = merge(
    var.default_tags,
    {},
  )
}

resource "azurerm_storage_account" "sa_tfstate" {
  name                     = "sa${var.tfstate_prefix}${random_string.random.result}"
  resource_group_name      = azurerm_resource_group.rg_management.name
  location                 = var.region
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_nested_items_to_be_public = false

  tags = merge(
    var.default_tags,
    {},
  )
}

resource "azurerm_storage_container" "sc_tfstate" {
  name                  = "sc-${var.tfstate_prefix}-${random_string.random.result}"
  storage_account_name  = azurerm_storage_account.sa_tfstate.name
  container_access_type = "private"
}