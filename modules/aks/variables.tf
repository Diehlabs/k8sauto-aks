variable "api_server_authorized_ip_ranges" {
  description = "Authorized IP ranages for API server. This is a list of one or more network addresses in CIDR format."
  type        = list(string)
}

variable "node_count" {
  description = "Number of nodes in cluster"
  type        = string
}

variable "dns_prefix" {
  description = "Cluster DNS Name Prefix"
  type        = string
}

variable "kubernetes_version_number" {
  description = "Kubernetes cluster version number"
  type        = string
}

variable "subnet" {
  description = "Data source for the subnet the cluster will be placed in"
  type = object({
    id = string
  })
}

variable "resource_group" {
  description = "The resource group that the AKS cluster will be created in"
  type = object({
    id       = string
    name     = string
    location = string
  })
}

variable "vm_size" {
  type        = string
  description = "VM size for AKS cluster nodes"
  default     = "Standard_DS3_v2"
}

variable "os_disk_size_gb" {
  type        = number
  description = "OS disk size for AKS cluster nodes"
  default     = 30
}

variable "node_pool_type" {
  type        = string
  description = "The node pool type for the AKS cluster"
  default     = "AvailabilitySet"
}

variable "az_tenant_id" {
  type        = string
  description = "The Azure subscription tenant ID. Defaults to the tenant ID that is input to the azurerm provider in the root module."
  default     = ""
}

variable "linux_profile" {
  description = "User name and SSH public key for the admin account on cluster hosts."
  type = object({
    username = string,
    sshkey   = string
  })
}

variable "nsg_rules" {
  description = "List of NSG rules to create"
  type        = any
  default     = {}
}

variable "docker_bridge_cidr" {
  type        = string
  description = "IP address (in CIDR notation) used as the Docker bridge IP address on nodes. Changing this forces a new resource to be created."
}

variable "dns_service_ip" {
  type        = string
  description = "IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns). Changing this forces a new resource to be created."
}

variable "service_cidr" {
  type        = string
  description = "The Network Range used by the Kubernetes service. Changing this forces a new resource to be created."
}

variable "private_dns_zone_id" {
  type        = string
  description = "Either the ID of Private DNS Zone which should be delegated to this Cluster, or System to have AKS manage this."
  default     = "System"
}

variable "private_cluster_enabled" {
  type        = bool
  description = "This provides a Private IP Address for the Kubernetes API on the Virtual Network where the Kubernetes Cluster is located. Defaults to false. Changing this forces a new resource to be created."
  default     = false
}

variable "tags" {
  description = "Tag information to be assigned to resources created."
  type = object({
    product           = string
    cost_center       = string
    environment       = string
    region            = string
    owner             = string
    technical_contact = string
  })
}

variable "network_security_group" {
  description = "The network security group to add AKS specific network rules to"
  type = object({
    name                = string
    resource_group_name = string
  })
}