locals {
  tags = {
    product           = "AKS Module Test-${var.azdo_build_id}"
    environment       = "test"
    region            = "westus"
    cost_center       = "01234"
    owner             = "me"
    technical_contact = "me"
  }
}