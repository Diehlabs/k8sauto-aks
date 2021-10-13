resource "azurerm_network_interface" "vm" {
  name                = "internal"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.core.outputs.subnets["control"]
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
    public_key = data.terraform_remote_state.core.outputs.ssh_key.public_key_openssh
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

resource "azurerm_network_security_group" "jump_box_ssh" {
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
  network_security_group_id = azurerm_network_security_group.jump_box_ssh.id
}

output "jump_box_ip" {
  value = azurerm_public_ip.vm.ip_address
}
