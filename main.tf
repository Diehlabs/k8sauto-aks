provider "azurerm" {
  features {}
}

locals {
  tags = data.terraform_remote_state.core.outputs.tags
}

resource "azurerm_resource_group" "aks" {
  name     = "aks"
  location = local.tags.region
  tags     = local.tags
}
resource "azurerm_network_security_group" "aks" {
  name                = "nsg-aksnodesub"
  location            = local.tags.region
  resource_group_name = azurerm_resource_group.aks.name
  tags                = local.tags
}

module "paks" {
  source                    = "./modules/aks"
  tags                      = local.tags
  resource_group            = azurerm_resource_group.aks
  subnet                    = data.terraform_remote_state.core.outputs.subnets["nodes"]
  docker_bridge_cidr        = "192.168.0.1/16"
  dns_service_ip            = "172.16.100.126"
  service_cidr              = "172.16.100.0/25"
  node_count                = 1
  dns_prefix                = "k8sa"
  kubernetes_version_number = var.k8s_version
  linux_profile = {
    username = "myk8sboss"
    sshkey   = data.terraform_remote_state.core.outputs.ssh_key.public_key_openssh
  }
  network_security_group = azurerm_network_security_group.aks
  cluster_admin_ids      = ["9ba4a348-227d-4411-bc37-3fb81ee8bc48"]
}
