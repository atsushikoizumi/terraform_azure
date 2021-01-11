# Create a virtual network within the resource group
resource "azurerm_virtual_network" "vnet01" {
  name                = "vnet01"
  resource_group_name = azurerm_resource_group.test01.name
  location            = azurerm_resource_group.test01.location
  address_space       = ["10.7.0.0/16"]
  tags = {
    "Owner" = "koizumi",
    "Env"   = "test01"
  }
}

# Create Subnets within the virtual network
resource "azurerm_subnet" "subnet01" {
  name                                           = "subnet01"
  virtual_network_name                           = azurerm_virtual_network.vnet01.name
  resource_group_name                            = azurerm_resource_group.test01.name
  enforce_private_link_endpoint_network_policies = false
  enforce_private_link_service_network_policies  = false
  address_prefixes                               = ["10.7.1.0/24"]
}

resource "azurerm_subnet" "subnet02" {
  name                                           = "subnet02"
  virtual_network_name                           = azurerm_virtual_network.vnet01.name
  resource_group_name                            = azurerm_resource_group.test01.name
  enforce_private_link_endpoint_network_policies = false
  enforce_private_link_service_network_policies  = false
  address_prefixes                               = ["10.7.2.0/24"]
  service_endpoints                              = ["Microsoft.Sql"]
}