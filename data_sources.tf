data "terraform_remote_state" "core" {
  backend = "remote"
  config = {
    organization = "Diehlabs"
    workspaces = {
      name = "iac-azure-aks"
    }
  }
}
