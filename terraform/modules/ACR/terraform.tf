terraform {
  required_version = ">= 1.7"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.84.0, < 4.0"
    }
  }
}