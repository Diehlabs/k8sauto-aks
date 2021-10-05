data "azurerm_client_config" "current" {}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = local.cluster_name
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version_number
  #private_dns_zone_id     = var.private_dns_zone_id
  private_cluster_enabled = var.private_cluster_enabled

  default_node_pool {
    name            = "nodes"
    node_count      = var.node_count
    vm_size         = var.vm_size
    os_disk_size_gb = var.os_disk_size_gb
    vnet_subnet_id  = var.subnet.id
    type            = var.node_pool_type
  }

  identity {
    type = "SystemAssigned"
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
    network_plugin     = "azure"
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
      managed = true
    }
  }

  api_server_authorized_ip_ranges = var.api_server_authorized_ip_ranges
}

resource "azurerm_network_security_rule" "aks" {
  for_each                    = local.nsg_rules_default
  name                        = each.key
  priority                    = each.value["priority"]
  direction                   = each.value["direction"]
  access                      = each.value["access"]
  protocol                    = each.value["protocol"]
  source_port_range           = each.value["source_port_range"]
  destination_port_range      = each.value["destination_port_range"]
  source_address_prefix       = each.value["source_address_prefix"]
  destination_address_prefix  = each.value["destination_address_prefix"]
  resource_group_name         = var.network_security_group.resource_group_name
  network_security_group_name = var.network_security_group.name
}