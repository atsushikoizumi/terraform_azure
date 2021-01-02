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

# Create 1 Subnet within the virtual network
resource "azurerm_subnet" "subnet01" {
  name                 = "subnet01"
  virtual_network_name = azurerm_virtual_network.vnet01.name
  resource_group_name  = azurerm_resource_group.test01.name
  address_prefixes     = ["10.7.1.0/24"]
}

# Create SecurityGroup
resource "azurerm_network_security_group" "sg01" {
  name                = "sg01"
  location            = azurerm_resource_group.test01.location
  resource_group_name = azurerm_resource_group.test01.name
  security_rule {
      name                       = "RDP"
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      source_address_prefix      = var.home_ip
      destination_port_range     = "3389"
      destination_application_security_group_ids = [azurerm_application_security_group.nicsg01.id]
  }
  tags = {
    "Owner" = "koizumi",
    "Env"   = "test01"
  }
}
resource "azurerm_application_security_group" "nicsg01" {
  name                = "nicsg01"
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
    public_ip_address_id = azurerm_public_ip.public01.id
  }
  tags = {
    "Owner" = "koizumi",
    "Env"   = "test01"
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_application_security_group_association" "nic01" {
    network_interface_id          = azurerm_network_interface.nic01.id
    application_security_group_id = azurerm_application_security_group.nicsg01.id
}

# Create Virtual Machine
resource "azurerm_windows_virtual_machine" "vm01" {
  name                = "vm01"
  resource_group_name = azurerm_resource_group.test01.name
  location            = azurerm_resource_group.test01.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.nic01.id,
  ]

  os_disk {
    name                 = "vm01_OsDisk_1"
    caching              = "None"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 128
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}