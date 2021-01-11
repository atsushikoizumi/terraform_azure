# Create SecurityGroups
resource "azurerm_network_security_group" "sg01" {
  name                = "sg01"
  location            = azurerm_resource_group.test01.location
  resource_group_name = azurerm_resource_group.test01.name
  security_rule {
    name                                       = "RDP-${azurerm_application_security_group.nicsg01.name}"
    priority                                   = 1000
    direction                                  = "Inbound"
    access                                     = "Allow"
    protocol                                   = "Tcp"
    source_port_range                          = "*"
    source_address_prefix                      = var.home_ip
    destination_port_range                     = "3389"
    destination_application_security_group_ids = [azurerm_application_security_group.nicsg01.id]
  }
  security_rule {
    name                                       = "RDP-${azurerm_application_security_group.nicsg02.name}"
    priority                                   = 1001
    direction                                  = "Inbound"
    access                                     = "Allow"
    protocol                                   = "Tcp"
    source_port_range                          = "*"
    source_address_prefix                      = var.home_ip
    destination_port_range                     = "3389"
    destination_application_security_group_ids = [azurerm_application_security_group.nicsg02.id]
  }
  security_rule {
    name                                       = "SQLServer"
    priority                                   = 1002
    direction                                  = "Inbound"
    access                                     = "Allow"
    protocol                                   = "Tcp"
    source_port_range                          = "*"
    source_application_security_group_ids      = [azurerm_application_security_group.nicsg01.id]
    destination_port_range                     = "1433"
    destination_application_security_group_ids = [azurerm_application_security_group.nicsg02.id]
  }
  tags = {
    "Owner" = "koizumi",
    "Env"   = "test01"
  }
}

resource "azurerm_network_security_group" "sg02" {
  name                = "sg02"
  location            = azurerm_resource_group.test01.location
  resource_group_name = azurerm_resource_group.test01.name
  security_rule {
    name                                  = "DenyALL"
    priority                              = 1002
    direction                             = "Inbound"
    access                                = "Deny"
    protocol                              = "*"
    source_port_range                     = "*"
    source_address_prefix                 = "*"
    destination_port_range                = "*"
    destination_address_prefix            = "*"
  }
  security_rule {
    name                                  = "SQLServer"
    priority                              = 1001
    direction                             = "Inbound"
    access                                = "Allow"
    protocol                              = "Tcp"
    source_port_range                     = "*"
    source_application_security_group_ids = [azurerm_application_security_group.nicsg01.id]
    destination_port_range                = "1433"
    destination_address_prefix            = "VirtualNetwork"
  }
  tags = {
    "Owner" = "koizumi",
    "Env"   = "test01"
  }
}

# Associates Network Security Groups with a Subnet
resource "azurerm_subnet_network_security_group_association" "sg01" {
  subnet_id                 = azurerm_subnet.subnet01.id
  network_security_group_id = azurerm_network_security_group.sg01.id
}

resource "azurerm_subnet_network_security_group_association" "sg02" {
  subnet_id                 = azurerm_subnet.subnet02.id
  network_security_group_id = azurerm_network_security_group.sg02.id
}