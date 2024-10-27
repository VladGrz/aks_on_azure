resource "azurerm_virtual_network" "machine" {
  name                = "machine"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.machine.location
  resource_group_name = azurerm_resource_group.machine.name

  tags = {
    env = local.env
  }

  depends_on = [
    azurerm_resource_group.machine
  ]
}