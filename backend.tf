terraform {
  backend "remote" {
    organization = "Diehlabs"
    workspaces {
      name = "k8sauto-aks-tgo"
    }
  }
}
