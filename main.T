terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  resource_provider_registrations = "none"
  features {}
  subscription_id = "0a9a10c1-c50a-4e9b-9bce-3c63a15baccd"
}

resource "azurerm_resource_group" "machine" {
  name     = "machine-resources"
  location = "West Europe"
}

resource "tls_private_key" "linux_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "linux_key_file" {
  filename = "linux_key.pem"
  content  = tls_private_key.linux_key.private_key_pem
}

resource "azurerm_virtual_network" "machine" {
  name                = "machine-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.machine.location
  resource_group_name = azurerm_resource_group.machine.name
}

resource "azurerm_subnet" "machine" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.machine.name
  virtual_network_name = azurerm_virtual_network.machine.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "machine" {
  name                = "machine-nic"
  location            = azurerm_resource_group.machine.location
  resource_group_name = azurerm_resource_group.machine.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.machine.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.machine_public_ip.id
  }
  depends_on = [
    azurerm_virtual_network.machine,
    azurerm_public_ip.machine_public_ip
  ]
}

resource "azurerm_storage_account" "machine" {
  name                     = "machinestorage6"
  resource_group_name      = azurerm_resource_group.machine.name
  location                 = azurerm_resource_group.machine.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

}

resource "azurerm_linux_virtual_machine" "linux_vm" {
  name                = "linuxvm"
  resource_group_name = azurerm_resource_group.machine.name
  location            = azurerm_resource_group.machine.location
  size                = "Standard_F2"
  admin_username      = "linuxusr"
  network_interface_ids = [
    azurerm_network_interface.machine.id,
  ]
  admin_ssh_key {
    username   = "linuxusr"
    public_key = tls_private_key.linux_key.public_key_openssh
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.machine,
    tls_private_key.linux_key
  ]
}

resource "azurerm_public_ip" "machine_public_ip" {
  name                = "machine-public-ip"
  resource_group_name = azurerm_resource_group.machine.name
  location            = azurerm_resource_group.machine.location
  allocation_method   = "Static"
  depends_on = [
    azurerm_resource_group.machine
  ]
}

resource "azurerm_network_security_group" "machine" {
  name                = "machine"
  location            = azurerm_resource_group.machine.location
  resource_group_name = azurerm_resource_group.machine.name
}

resource "azurerm_network_security_rule" "machine" {
  name                        = "allow_ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.machine.name
  network_security_group_name = azurerm_network_security_group.machine.name
}