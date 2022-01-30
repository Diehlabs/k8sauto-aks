locals {
  tags = {
    owner             = "tgo"
    region            = "centralus"
    product           = "myaks"
    cost_center       = "0666"
    environment       = "notprod"
    technical_contact = "lynch"
  }
  nsg_rules = {
    HTTP = {
      name                       = "allow-tcp-80-inbound"
      priority                   = 140
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    SSL = {
      name                       = "allow-tcp-443-inbound"
      priority                   = 150
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    SSH = {
      name                       = "allow-tcp-22-inbound"
      priority                   = 151
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    KUBEAPI = {
      name                       = "allow-tcp-6443-inbound"
      priority                   = 145
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "6443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
  }
}
