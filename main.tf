provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "aks" {
  name     = "aks"
  location = local.tags.region
  tags     = local.tags
}

module "paks" {
  source                    = "./modules/aks"
  tags                      = local.tags
  resource_group            = azurerm_resource_group.aks
  subnet                    = azurerm_subnet.aks
  docker_bridge_cidr        = "192.168.10.1/16"
  dns_service_ip            = "172.16.100.126"
  service_cidr              = "172.16.100.0/25"
  node_count                = 1
  dns_prefix                = "k8sa"
  kubernetes_version_number = var.k8s_version
  linux_profile = {
    username = "adminuser"
    sshkey   = tls_private_key.aks.public_key_openssh
  }
  cluster_admin_ids   = ["9ba4a348-227d-4411-bc37-3fb81ee8bc48"]
  private_dns_zone_id = azurerm_private_dns_zone.tgo.id
}

resource "local_file" "kube_config_admin" {
  content  = module.paks.kube_admin_config
  filename = "./admin.kubeconfig" # ~/.kube/config
}

resource "tls_private_key" "aks" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
