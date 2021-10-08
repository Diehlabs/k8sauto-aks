provider "azurerm" {
  features {}
}

locals {
  tags = {
    region            = "westus"
    environment       = "dev"
    cost_center       = "06660"
    owner             = "t-go"
    product           = "private-aks"
    technical_contact = "def-not-me"
  }
}

resource "azurerm_resource_group" "aks" {
  name     = "aks"
  location = local.tags.region
  tags     = local.tags
}

resource "azurerm_network_security_group" "aks_nsg" {
  name                = "paks_nsg"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
}

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
  tags = local.tags
}

resource "azurerm_subnet" "akscontrolsub" {
  name                 = "akscontrolsub"
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.aksvnet.name
  address_prefixes     = ["172.16.0.0/24"]
}

resource "azurerm_subnet" "aksnodesub" {
  name                 = "aksnodesub"
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.aksvnet.name
  address_prefixes     = ["172.16.1.0/24"]
}

resource "tls_private_key" "paks" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

module "paks" {
  source         = "./modules/aks"
  tags           = local.tags
  resource_group = azurerm_resource_group.aks
  subnet         = azurerm_subnet.aksnodesub
  # api_server_authorized_ip_ranges = [
  #   #azurerm_virtual_network.aksvnet.address_space[0],
  #   azurerm_subnet.aksnodesub.address_prefixes[0]

  # ]
  docker_bridge_cidr        = "192.168.0.1/16"
  dns_service_ip            = "172.16.0.126"
  service_cidr              = "172.16.0.0/25"
  node_count                = 1
  dns_prefix                = "k8sa"
  kubernetes_version_number = var.k8s_version
  linux_profile = {
    username = "myk8sboss"
    sshkey   = tls_private_key.paks.public_key_openssh
  }
  network_security_group = azurerm_network_security_group.aks_nsg
}
