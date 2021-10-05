# provider "helm" {
#   kubernetes {
#     host = azurerm_kubernetes_cluster.aks.kube_config.0.host
#     username = azurerm_kubernetes_cluster.aks.kube_config.0.username
#     password = azurerm_kubernetes_cluster.aks.kube_config.0.password
#     client_certificate = azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_certificate
#     client_key = azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_key
#     cluster_ca_certificate = azurerm_kubernetes_cluster.aks.kube_admin_config.0.cluster_ca_certificate
#   }
#   debug = true
# }

provider "helm" {
  kubernetes {
    host                   = module.paks.host
    username               = module.paks.cluster_username
    password               = module.paks.cluster_password
    client_certificate     = module.paks.client_certificate
    client_key             = module.paks.client_key
    cluster_ca_certificate = module.paks.cluster_ca_certificate
  }
  debug = true
}

resource "helm_release" "csi-secrets-store-provider-azure" {
  name       = "csi"
  repository = "https://raw.githubusercontent.com/Azure/secrets-store-csi-driver-provider-azure/master/charts"
  chart      = "csi-secrets-store-provider-azure"
  #version    = "0.0.16"
}

# https://github.com/weaveworks/kured/tree/master/charts/kured
resource "helm_release" "kured" {
  name       = "kured"
  repository = "https://weaveworks.github.io/kured"
  chart      = "kured"
}

# resource "helm_release" "aad-pod-identity" {
#   name       = "aad-pod-identity"
#   repository = "https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts"
#   chart      = "aad-pod-identity"
# }

# resource "local_file" "kubeconfig" {
#   content = azurerm_kubernetes_cluster.aks.kube_config_raw
#   filename = "./kubeconfig"
# }

# provider "helm" {
#   kubernetes {
#     config_path = local_file.kubeconfig.filename
#   }
#   debug = true
# }

