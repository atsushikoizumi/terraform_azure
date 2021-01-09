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

# Create SecurityGroups
resource "azurerm_network_security_group" "sg01" {
  name                = "sg01"
  location            = azurerm_resource_group.test01.location
  resource_group_name = azurerm_resource_group.test01.name
  security_rule {
    name                                       = "RDP"
    priority                                   = 1001
    direction                                  = "Inbound"
    access                                     = "Allow"
    protocol                                   = "Tcp"
    source_port_range                          = "*"
    source_address_prefix                      = var.home_ip
    destination_port_range                     = "3389"
    destination_application_security_group_ids = [azurerm_application_security_group.nicsg01.id]
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
  tags = {
    "Owner" = "koizumi",
    "Env"   = "test01"
  }
}

# Create Storage Account
resource "azurerm_storage_account" "test01" {
  name                     = "koizumitest01sqlserver"
  resource_group_name      = azurerm_resource_group.test01.name
  location                 = azurerm_resource_group.test01.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    "Owner" = "koizumi",
    "Env"   = "test01"
  }
}

# Create SQL Serrver
# CREATE LOGIN xx_adm WITH PASSWORD = 'abc123X!'
# [use master] CREATE USER xx_adm FOR LOGIN xx_adm WITH DEFAULT_SCHEMA = dbo
resource "azurerm_mssql_server" "sqlserver01" {
  name                          = "koizumi-sqlserver01"
  resource_group_name           = azurerm_resource_group.test01.name
  location                      = azurerm_resource_group.test01.location
  version                       = "12.0"
  administrator_login           = "adminsqlserver"
  administrator_login_password  = "P@$$w0rd1234!"
  public_network_access_enabled = true
  tags = {
    "Owner" = "koizumi",
    "Env"   = "test01"
  }
}

# Create VNet for SQL Server
resource "azurerm_sql_virtual_network_rule" "sqlvnetrule01" {
  name                = "sqlvnetrule01"
  resource_group_name = azurerm_resource_group.test01.name
  server_name         = azurerm_mssql_server.sqlserver01.name
  subnet_id           = azurerm_subnet.subnet02.id
}

# SQLServer FireWall
resource "azurerm_sql_firewall_rule" "sqlfirewall01" {
  name                = "sqlfirewall01"
  resource_group_name = azurerm_resource_group.test01.name
  server_name         = azurerm_mssql_server.sqlserver01.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_sql_firewall_rule" "sqlfirewall02" {
  name                = "sqlfirewall02"
  resource_group_name = azurerm_resource_group.test01.name
  server_name         = azurerm_mssql_server.sqlserver01.name
  start_ip_address    = azurerm_network_interface.nic01.private_ip_address
  end_ip_address      = azurerm_network_interface.nic01.private_ip_address
}

# Extended auditting policy
resource "azurerm_mssql_server_extended_auditing_policy" "test01" {
  server_id                               = azurerm_mssql_server.sqlserver01.id
  storage_endpoint                        = azurerm_storage_account.test01.primary_blob_endpoint
  storage_account_access_key              = azurerm_storage_account.test01.primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = 6
}

# Create SQL Database
# CREATE USER xx_adm FOR LOGIN xx_adm WITH DEFAULT_SCHEMA = dbo
# ALTER ROLE db_owner ADD MEMBER xx_adm
resource "azurerm_mssql_database" "test01" {
  name           = "test01"
  server_id      = azurerm_mssql_server.sqlserver01.id
  sku_name       = "S1"
  max_size_gb    = 250
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  read_scale     = false
  zone_redundant = false
  tags = {
    "Owner" = "koizumi",
    "Env"   = "test01"
  }
}
