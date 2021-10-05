provider "azurerm" {
  features {}
  subscription_id = data.vault_generic_secret.az_spn_svc_tfe_myteam_devtest.data.subscription_id
  client_id       = data.vault_generic_secret.az_spn_svc_tfe_myteam_devtest.data.client_id
  client_secret   = data.vault_generic_secret.az_spn_svc_tfe_myteam_devtest.data.client_secret
  tenant_id       = data.vault_generic_secret.az_spn_svc_tfe_myteam_devtest.data.tenant_id
}

data "terraform_remote_state" "devtest_resources" {
  backend = "remote"
  config = {
    hostname     = "tfe.diehlabs.com"
    organization = "diehlabs"
    workspaces = {
      name = "core-entauto-terraform-azure-devtest"
    }
  }
}

resource "azurerm_network_security_group" "aks" {
  name                = "cloudauto-aks-module-test-nsg-${var.azdo_build_id}"
  location            = data.terraform_remote_state.devtest_resources.outputs.rg.location
  resource_group_name = data.terraform_remote_state.devtest_resources.outputs.rg.name
  tags                = local.tags
}

module "aks_ci" {
  source         = "./modules/example"
  tags           = local.tags
  resource_group = data.terraform_remote_state.devtest_resources.outputs.rg
  subnet         = data.terraform_remote_state.devtest_resources.outputs.subnets["mysubnetname"]
  api_server_authorized_ip_ranges = [
    data.terraform_remote_state.devtest_resources.outputs.vnet.address_space[0],
    "10.35.210.0/24"
  ]
  docker_bridge_cidr        = "192.168.0.1/16"
  dns_service_ip            = "63.96.91.126"
  service_cidr              = "63.96.91.0/25"
  node_count                = 1
  dns_prefix                = "cla"
  kubernetes_version_number = "1.21.1"
  linux_profile = {
    username = "myk8sboss"
    sshkey   = data.vault_generic_secret.myapp_ssh_key.data.public_key_openssh
  }
  network_security_group = azurerm_network_security_group.aks
}
