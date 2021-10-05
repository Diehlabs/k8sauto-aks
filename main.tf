provider "azurerm" {
  features {}
}

locals {
  tags = {
    location    = "westus"
    environment = "dev"
  }
}

resource "azurerm_resource_group" "aks" {
  name     = "aks"
  location = local.tags.location
  tags     = local.tags
}

// resource "azurerm_network_security_group" "tkg_nsg" {
//   name                = "tanzu_nsg"
//   location            = tkg.location
//   resource_group_name = tkg.name
// }

resource "azurerm_virtual_network" "aksvnet" {
  name                = "aksnet"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  address_space       = ["172.16.0.0/23"]
  #dns_servers         = ["10.0.0.4", "10.0.0.5"]

  // ddos_protection_plan {
  //   id     = azurerm_network_ddos_protection_plan.example.id
  //   enable = true
  // }

  subnet {
    name           = "akscontrolsub"
    address_prefix = "172.16.0.0/24"
  }

  subnet {
    name           = "aksnodesub"
    address_prefix = "172.16.1.0/24"
  }

  tags = local.tags
}