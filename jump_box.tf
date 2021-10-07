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

# resource "azurerm_network_interface" "vm_pub" {
#   name                = "public"
#   location            = azurerm_resource_group.aks.location
#   resource_group_name = azurerm_resource_group.aks.name

#   ip_configuration {
#     name                          = "public"
#     subnet_id                     = azurerm_subnet.aksnodesub.id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = azurerm_public_ip.vm.id
#   }
# }

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "jump-box1"
  location                        = azurerm_resource_group.aks.location
  resource_group_name             = azurerm_resource_group.aks.name
  size                            = "Standard_B1LS"
  admin_username                  = "adminuser"
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.vm.id,
    #azurerm_network_interface.vm_pub.id,
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
    # publisher = "Canonical"
    # offer     = "UbuntuServer"
    # sku       = "20_04-lts-gen1"
    # version   = "latest"
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

resource "null_resource" "cluster" {
  depends_on = [
    azurerm_linux_virtual_machine.vm,
    azurerm_network_interface_security_group_association.vm_ssh
  ]

  connection {
    user        = "adminuser"
    type        = "ssh"
    private_key = tls_private_key.paks.private_key_pem
    host        = azurerm_public_ip.vm.ip_address
  }

  provisioner "file" {
    source      = module.paks.kube_config
    destination = "/home/adminuser/.kube/config"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo curl -LO https://dl.k8s.io/release/${var.k8s_version}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl",
      "sudo chmod +x /usr/local/bin/kubectl"
    ]
  }
}

resource "null_resource" "azcli" {
  depends_on = [
    azurerm_linux_virtual_machine.vm,
    azurerm_network_interface_security_group_association.vm_ssh,
    null_resource.cluster
  ]

  connection {
    user        = "adminuser"
    type        = "ssh"
    private_key = tls_private_key.paks.private_key_pem
    host        = azurerm_public_ip.vm.ip_address
  }
  
  provisioner "remote-exec" {
    inline = [
      "az aks install-cli",
      "az aks get-credentials --resource-group ${azurerm_resource_group.aks} --name ${module.paks.cluster_name}"
    ]
  }
}

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
  #network_interface_id      = azurerm_network_interface.vm_pub.id
  network_interface_id      = azurerm_network_interface.vm.id
  network_security_group_id = azurerm_network_security_group.aksnodesub.id
}

output "jump_box_ip" {
  value = azurerm_public_ip.vm.id
}