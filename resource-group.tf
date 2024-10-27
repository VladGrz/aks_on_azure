resource "azurerm_resource_group" "machine" {
  name     = local.resource_group_name
  location = local.region
}
