resource "azurerm_virtual_network" "aks" {
  name                = "aks-vnet"
  location            = local.tags.region
  resource_group_name = azurerm_resource_group.aks.name
  address_space       = ["10.0.10.0/24"]
  tags                = local.tags
}

resource "azurerm_subnet" "aks" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefixes     = ["10.0.10.0/25"]
}

resource "azurerm_network_security_group" "aks" {
  name                = "nsg-aksnodesub"
  location            = local.tags.region
  resource_group_name = azurerm_resource_group.aks.name
  tags                = local.tags
}

resource "azurerm_network_security_rule" "aks" {
  for_each                    = local.nsg_rules
  name                        = each.key
  priority                    = each.value["priority"]
  direction                   = each.value["direction"]
  access                      = each.value["access"]
  protocol                    = each.value["protocol"]
  source_port_range           = each.value["source_port_range"]
  destination_port_range      = each.value["destination_port_range"]
  source_address_prefix       = each.value["source_address_prefix"]
  destination_address_prefix  = each.value["destination_address_prefix"]
  resource_group_name         = azurerm_resource_group.aks.name
  network_security_group_name = azurerm_network_security_group.aks.name
}

resource "azurerm_private_dns_zone" "tgo" {
  name                = "tgo.privatelink.centralus.azmk8s.io"
  resource_group_name = azurerm_resource_group.aks
  tags                = local.tags
}
