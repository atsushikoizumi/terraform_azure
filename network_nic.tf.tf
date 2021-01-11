##########################
###### NIC for vm01 ###### 
##########################

# Public ip address
resource "azurerm_public_ip" "public01" {
  name                = "public01"
  resource_group_name = azurerm_resource_group.test01.name
  location            = azurerm_resource_group.test01.location
  domain_name_label   = "public01"
  allocation_method   = "Dynamic"
  tags = {
    "Owner" = "koizumi",
    "Env"   = "test01"
  }
}

# Create Network Interface Card
resource "azurerm_network_interface" "nic01" {
  name                = "nic01"
  location            = azurerm_resource_group.test01.location
  resource_group_name = azurerm_resource_group.test01.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet01.id
    private_ip_address_version    = "IPv4"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public01.id
  }
  tags = {
    "Owner" = "koizumi",
    "Env"   = "test01"
  }
}

# Create Application Security Group
resource "azurerm_application_security_group" "nicsg01" {
  name                = "nicsg01"
  location            = azurerm_resource_group.test01.location
  resource_group_name = azurerm_resource_group.test01.name
  tags = {
    "Owner" = "koizumi",
    "Env"   = "test01"
  }
}

# Connect the Application Security Group to the network interface
resource "azurerm_network_interface_application_security_group_association" "nic01" {
  network_interface_id          = azurerm_network_interface.nic01.id
  application_security_group_id = azurerm_application_security_group.nicsg01.id
}



##########################
###### NIC for vm02 ######
##########################

# Public ip address
resource "azurerm_public_ip" "public02" {
  name                = "public02"
  resource_group_name = azurerm_resource_group.test01.name
  location            = azurerm_resource_group.test01.location
  domain_name_label   = "public02"
  allocation_method   = "Dynamic"
  tags = {
    "Owner" = "koizumi",
    "Env"   = "test01"
  }
}

# Create Network Interface Card
resource "azurerm_network_interface" "nic02" {
  name                = "nic02"
  location            = azurerm_resource_group.test01.location
  resource_group_name = azurerm_resource_group.test01.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet01.id
    private_ip_address_version    = "IPv4"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public02.id
  }
  tags = {
    "Owner" = "koizumi",
    "Env"   = "test01"
  }
}

# Create Application Security Group
resource "azurerm_application_security_group" "nicsg02" {
  name                = "nicsg02"
  location            = azurerm_resource_group.test01.location
  resource_group_name = azurerm_resource_group.test01.name
  tags = {
    "Owner" = "koizumi",
    "Env"   = "test01"
  }
}

# Connect the Application Security Group to the network interface
resource "azurerm_network_interface_application_security_group_association" "nic02" {
  network_interface_id          = azurerm_network_interface.nic02.id
  application_security_group_id = azurerm_application_security_group.nicsg02.id
}


