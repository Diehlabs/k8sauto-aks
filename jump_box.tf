resource "azurerm_network_interface" "vm" {
  name                = "internal"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.akscontrolsub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }

  tags = local.tags
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "jump-box1"
  location                        = azurerm_resource_group.aks.location
  resource_group_name             = azurerm_resource_group.aks.name
  size                            = "Standard_B1ls"
  admin_username                  = "adminuser"
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.vm.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.paks.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = local.tags
}

resource "azurerm_public_ip" "vm" {
  name                = "jump-box-pip"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  allocation_method   = "Static"

  tags = local.tags
}

resource "local_file" "ansible_invtory" {
  filename = "${path.module}/ansible/inventory.yml"
  content = templatefile("${path.module}/ansible/inventory.yml.tpl", {
    user_id = "adminuser"
    host_ip = azurerm_public_ip.vm.ip_address
    k8s_version = var.k8s_version
    kubeconf_content = sensitive(base64encode(module.paks.kube_config))
  })
}

resource "local_file" "rsa_key" {
  filename = "${path.module}/ansible/rsa.key"
  content = tls_private_key.paks.private_key
}

resource "null_resource" "ansible" {
  depends_on = [
    local_file.ansible_invtory,
    local_file.rsa_key,
  ]
  provisioner "local-exec" {
    inline = [
      "pip3 install ansible",
      "ansible-playbook ${path.module}/ansible/setup.yml -i ${path.module}/ansible/inventory.yml --private-key ${path.module}/ansible/rsa.key",
    ]
  }
}

# resource "null_resource" "cluster" {
#   depends_on = [
#     azurerm_linux_virtual_machine.vm,
#     azurerm_network_interface_security_group_association.vm_ssh
#   ]

#   connection {
#     user        = "adminuser"
#     type        = "ssh"
#     private_key = tls_private_key.paks.private_key_pem
#     host        = azurerm_public_ip.vm.ip_address
#   }

#   provisioner "remote-exec" {
#     script = templatefile("scripts/script1.sh", { k8s_ver = var.k8s_version })
#   }

#   provisioner "file" {
#     content     = sensitive(module.paks.kube_config)
#     destination = "/home/adminuser/.kube/config"
#   }
# }

# resource "null_resource" "azcli" {
#   depends_on = [
#     azurerm_linux_virtual_machine.vm,
#     azurerm_network_interface_security_group_association.vm_ssh,
#     null_resource.cluster
#   ]

#   connection {
#     user        = "adminuser"
#     type        = "ssh"
#     private_key = tls_private_key.paks.private_key_pem
#     host        = azurerm_public_ip.vm.ip_address
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "az aks install-cli",
#       "az aks get-credentials --resource-group ${azurerm_resource_group.aks} --name ${module.paks.cluster_name}"
#     ]
#   }
# }

resource "azurerm_network_security_group" "aksnodesub" {
  name                = "nsg-aksnodesub"
  location            = local.tags.region
  resource_group_name = azurerm_resource_group.aks.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = local.tags
}
resource "azurerm_network_interface_security_group_association" "vm_ssh" {
  network_interface_id      = azurerm_network_interface.vm.id
  network_security_group_id = azurerm_network_security_group.aksnodesub.id
}

output "jump_box_ip" {
  value = azurerm_public_ip.vm.id
}