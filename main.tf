provider "azurerm" {
  features {}
}

locals {
  tags = {
    location    = "westus"
    environment = "dev"
  }
}

resource "azurerm_resource_group" "tkg" {
  name     = "tanzu"
  location = local.tags.location
  tags     = local.tags
}