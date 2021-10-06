resource "azurerm_network_interface" "vm" {
  name                = "example-nic"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.akscontrolsub.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = local.tags
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "jump-box"
  location                        = azurerm_resource_group.aks.location
  resource_group_name             = azurerm_resource_group.aks.name
  size                            = "Standard_B1LS"
  admin_username                  = "adminuser"
  disable_password_authentication = true
  network_interface_ids = [
    azurerm_network_interface.vm.id,
  ]

  admin_ssh_key {
    username   = "thevitch"
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
  depends_on = [azurerm_linux_virtual_machine.vm]

  connection {
    type        = "ssh"
    private_key = tls_private_key.paks.private_key_pem
    host        = azurerm_public_ip.vm.ip_address
  }

  provisioner "file" {
    source      = module.paks.kube_config
    destination = "/root/kube_config_aks"
  }
}

resource "azurerm_network_security_group" "akscontrolsub" {
  name                = "nsg-akscontrolsub"
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
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.vm.id
  network_security_group_id = azurerm_network_security_group.akscontrolsub.id
}