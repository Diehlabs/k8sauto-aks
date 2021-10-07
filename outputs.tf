output "ssh_key" {
  value     = tls_private_key.paks
  sensitive = true
}

output "jump_box_up" {
  value  = azurerm_public_ip.vm.id
}

# output "kube_config" {
#   value     = module.paks.kube_config
#   sensitive = true
# }