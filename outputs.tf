output "kube_config" {
  value     = module.paks.kube_config
  sensitive = true
}

output "kube_admin_config" {
  value     = module.paks.kube_admin_config
  sensitive = true
}

output "k8s_version" {
  value = var.k8s_version
}
