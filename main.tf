# Create a resource group
resource "azurerm_resource_group" "test01" {
  name     = "atsushi.koizumi.test01"
  location = "East US"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "test01" {
  name                = "test01"
  resource_group_name = azurerm_resource_group.test01.name
  location            = azurerm_resource_group.test01.location
  address_space       = ["10.0.0.0/16"]
}