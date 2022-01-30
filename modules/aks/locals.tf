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
}
