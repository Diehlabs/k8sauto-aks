data "azurerm_client_config" "current" {}

data "azurerm_subscription" "primary" {}

data "azurerm_role_definition" "privateDNSZoneContrib" {
  name = "Private DNS Zone Contributor"
}

resource "azurerm_user_assigned_identity" "dns" {
  name                = "aks-dns-identity"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
}


resource "azurerm_role_assignment" "aks-dns" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.dns.principal_id
}

resource "azurerm_role_assignment" "aks-network" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.dns.principal_id
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                    = local.cluster_name
  location                = var.resource_group.location
  resource_group_name     = var.resource_group.name
  kubernetes_version      = var.kubernetes_version_number
  private_cluster_enabled = false
  dns_prefix              = var.dns_prefix
  private_dns_zone_id     = var.private_dns_zone_id

  default_node_pool {
    name            = "nodes"
    node_count      = var.node_count
    vm_size         = var.vm_size
    os_disk_size_gb = var.os_disk_size_gb
    vnet_subnet_id  = var.subnet.id
    type            = var.node_pool_type
  }

  identity {
    type                      = "UserAssigned"
    user_assigned_identity_id = azurerm_user_assigned_identity.dns.id
  }

  linux_profile {
    admin_username = var.linux_profile.username
    ssh_key {
      key_data = var.linux_profile.sshkey
    }
  }

  addon_profile {
    http_application_routing {
      enabled = false
    }
  }

  # verify that these items are needed, we think they are, possibly srd requirement
  network_profile {
    network_plugin     = "kubenet"
    network_policy     = "calico"
    load_balancer_sku  = "standard"
    docker_bridge_cidr = var.docker_bridge_cidr
    dns_service_ip     = var.dns_service_ip
    service_cidr       = var.service_cidr
  }

  tags = var.tags

  role_based_access_control {
    enabled = true
    azure_active_directory {
      managed                = true
      admin_group_object_ids = var.cluster_admin_ids
    }
  }
  depends_on = [
    azurerm_role_assignment.aks-network,
  ]

  # api_server_authorized_ip_ranges = var.api_server_authorized_ip_ranges
}
