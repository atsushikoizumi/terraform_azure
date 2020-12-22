# Create a resource group
resource "azurerm_resource_group" "test01" {
  name     = "atsushi.koizumi.test01"
  location = "East US"
  tags = {
    "Owner" = "koizumi",
    "Env"   = "test01"
  }
}

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

# Create 2 Subnets within the virtual network
resource "azurerm_subnet" "subnet01" {
  name                 = "subnet01"
  virtual_network_name = azurerm_virtual_network.vnet01.name
  resource_group_name  = azurerm_resource_group.test01.name
  address_prefixes     = ["10.7.1.0/24"]
}
resource "azurerm_subnet" "subnet02" {
  name                 = "subnet02"
  virtual_network_name = azurerm_virtual_network.vnet01.name
  resource_group_name  = azurerm_resource_group.test01.name
  address_prefixes     = ["10.7.2.0/24"]
}

# Create 2 SecurityGroups
resource "azurerm_network_security_group" "sg01" {
  name                = "sg01"
  location            = azurerm_resource_group.test01.location
  resource_group_name = azurerm_resource_group.test01.name
  tags = {
    "Owner" = "koizumi",
    "Env"   = "test01"
  }
}
resource "azurerm_network_security_group" "sg02" {
  name                = "sg02"
  location            = azurerm_resource_group.test01.location
  resource_group_name = azurerm_resource_group.test01.name
  tags = {
    "Owner" = "koizumi",
    "Env"   = "test01"
  }
}


# Associates a Network Security Group with a Subnet 
resource "azurerm_subnet_network_security_group_association" "sg01" {
  subnet_id                 = azurerm_subnet.subnet01.id
  network_security_group_id = azurerm_network_security_group.sg01.id
}
resource "azurerm_subnet_network_security_group_association" "sg02" {
  subnet_id                 = azurerm_subnet.subnet02.id
  network_security_group_id = azurerm_network_security_group.sg02.id
}
