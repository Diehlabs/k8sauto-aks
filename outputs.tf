output "ssh_key" {
  value     = base64encode(tls_private_key.paks.private_key_pem)
  sensitive = true
}

output "kube_config" {
  value     = module.paks.kube_config
  sensitive = true
}

output "kube_admin_config" {
  value     = module.paks.kube_admin_config
  sensitive = true
}
