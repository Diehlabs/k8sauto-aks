output "ssh_key" {
  value = tls_private_key.paks
}

output "kube_config" {
  value = module.paks.kube_config
}