output "resource_group_name" {
  value = azurerm_resource_group.rg_management.name
}

output sa_tfstate {
  value       = azurerm_storage_account.sa_tfstate.name
  description = "Remote tfstate Storage Account name"
  depends_on  = [azurerm_storage_account.sa_tfstate]
}

output sc_tfstate {
  value       = azurerm_storage_container.sc_tfstate.name
  description = "Remote tfstate Storage Account name"
  depends_on  = [azurerm_storage_container.sc_tfstate]
}
