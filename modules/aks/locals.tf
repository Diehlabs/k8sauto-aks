locals {
  # tags = {
  #   product           = var.product
  #   environment       = var.environment
  #   region            = var.location
  #   cost_center       = var.cost_center
  #   owner             = var.owner
  #   technical_contact = var.technical_contact
  # }

  #cluster_name = replace(lower("${var.product}-${var.location}-${var.environment}"), " ", "_")
  cluster_name = replace(lower("${var.tags.product}-${var.tags.region}-${var.tags.environment}"), " ", "_")

  tenant_id = var.az_tenant_id == "" ? data.azurerm_client_config.current.tenant_id : var.az_tenant_id

  nsg_rules_default = {
    deny_tcp_10250_inbound = {
      name                       = "deny-tcp-10250-inbound"
      priority                   = 500
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "10250"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    deny_tcp_10255_inbound = {
      name                       = "deny-tcp-10255-inbound"
      priority                   = 510
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "10255"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  // nsg_rules = merge(local.nsg_rules_default, var.nsg_rules)

}