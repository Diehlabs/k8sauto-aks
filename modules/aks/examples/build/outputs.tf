# output "client_key" {
#   value     = module.aks_ci.client_key
#   sensitive = true
# }

# output "client_certificate" {
#   value     = module.aks_ci.client_certificate
#   sensitive = true
# }

# output "cluster_ca_certificate" {
#   value     = module.aks_ci.cluster_ca_certificate
#   sensitive = true
# }

# output "cluster_username" {
#   value = module.aks_ci.username
# }

# output "cluster_password" {
#   value     = module.aks_ci.password
#   sensitive = true
# }

# output "kube_config" {
#   value     = module.aks_ci.kube_config_raw
#   sensitive = true
# }

# output "host" {
#   value     = module.aks_ci.host
#   sensitive = true
# }

# output "kube_admin_password" {
#   value     = module.aks_ci.kube_admin_config.0.password
#   sensitive = true
# }

# output "kube_admin_client_certificate" {
#   value     = module.aks_ci.kube_admin_config.0.client_certificate
#   sensitive = true
# }

# output "kube_admin_client_key" {
#   value     = module.aks_ci.kube_admin_config.0.client_key
#   sensitive = true
# }

# output "kube_admin_cluster_ca_certificate" {
#   value     = module.aks_ci.kube_admin_config.0.cluster_ca_certificate
#   sensitive = true
# }

output "cluster_name" {
  value = module.aks_ci.cluster_name
}

output "admin_user_name" {
  value     = "myk8sboss"
  sensitive = true
}

output "ssh_private_key" {
  value     = base64decode(data.vault_generic_secret.myapp_ssh_key.data.private_key_pem_b64)
  sensitive = true
}

output "ssh_public_key" {
  value     = base64decode(data.vault_generic_secret.myapp_ssh_key.data.public_key_pem_b64)
  sensitive = true
}

output "cluster_fqdn" {
  value = module.aks_ci.cluster_fqdn
}