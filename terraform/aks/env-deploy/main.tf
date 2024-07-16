provider "azurerm" {
  features {}
}

terraform {
  required_version = ">= 1.7"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.84.0, < 4.0"
    }
  }
  backend "azurerm" {
      resource_group_name  = "rg-management-cg67p"
      storage_account_name = "satfstatecg67p"
      container_name       = "sc-tfstate-cg67p"
      key                  = "terraform.tfstate"
  }
}

resource "random_string" "random" {
    length = 5
    special = false
    upper   = false
}


resource "azurerm_resource_group" "rg" {
  name     = "${var.rg_prefix}-${random_string.random.result}"
  location = var.region

  tags = merge(
    var.default_tags,
    {},
  )
}