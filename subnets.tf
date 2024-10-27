resource "azurerm_subnet" "machine_subnet_1" {
  name                 = "subnet_1"
  resource_group_name  = azurerm_resource_group.machine.name
  virtual_network_name = azurerm_virtual_network.machine.name
  address_prefixes     = ["10.0.0.0/19"]
}

resource "azurerm_subnet" "machine_subnet_2" {
  name                 = "subnet_2"
  resource_group_name  = azurerm_resource_group.machine.name
  virtual_network_name = azurerm_virtual_network.machine.name
  address_prefixes     = ["10.0.32.0/19"]
}
