terraform {
  backend "remote" {
    organization = "Diehlabs"

    workspaces {
      name = "iac-aks"
    }
  }
}
