terraform {
  required_version = "~> 1.0.0"
  required_providers {
    github = {
      source  = "hashicorp/azurerm"
      version = ">= 2.77.0"
    }
  }
}
