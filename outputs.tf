output "ssh_key" {
  value     = base64encode(tls_private_key.paks)
  sensitive = true
}

# output "kube_config" {
#   value     = module.paks.kube_config
#   sensitive = true
# }