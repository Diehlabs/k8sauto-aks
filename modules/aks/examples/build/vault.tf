data "terraform_remote_state" "vault_mgmt" {
  backend = "remote"
  config = {
    hostname     = "tfe.diehlabs.com"
    organization = "Diehlabs"
    workspaces = {
      name = "core-entauto-terraform-vault-mgmt"
    }
  }
}

provider "vault" {
  address = "https://vault.diehlabs.com:443"
  auth_login {
    path = "auth/approle/login"
    parameters = {
      role_id   = data.terraform_remote_state.vault_mgmt.outputs.prod.ro.id
      secret_id = data.terraform_remote_state.vault_mgmt.outputs.prod.ro.secret
    }
  }
}

data "vault_generic_secret" "az_spn_svc_tfe_myteam_devtest" {
  path = "cloudauto/terraform/prod/azure/spn_infra"
}

data "vault_generic_secret" "myapp_ssh_key" {
  path = "cloudauto/terraform/prod/myapp/myapp_ssh_key"
}