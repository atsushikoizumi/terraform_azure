# Create VirtualMachine
resource "azurerm_windows_virtual_machine" "vm02" {
  name                = "vm02"
  resource_group_name = azurerm_resource_group.test01.name
  location            = azurerm_resource_group.test01.location
  size                = "Standard_B2ms"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  timezone            = "Tokyo Standard Time"
  network_interface_ids = [
    azurerm_network_interface.nic02.id,
  ]
  source_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "sql2019-ws2019"
    sku       = "standard"
    version   = "latest"
  }
  os_disk {
    name                 = "vm02_OsDisk_1"
    caching              = "None"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 128
  }
  tags = {
    "Owner" = "koizumi",
    "Env"   = "test01"
  }
}

# Create Managed Disk
resource "azurerm_managed_disk" "vm02_OsDisk_2" {
  name                 = "vm02_OsDisk_2"
  location             = azurerm_resource_group.test01.location
  resource_group_name  = azurerm_resource_group.test01.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 128
}

# Attach Disk to vm02
resource "azurerm_virtual_machine_data_disk_attachment" "vm02_OsDisk_2" {
  managed_disk_id    = azurerm_managed_disk.vm02_OsDisk_2.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm02.id
  lun                = "2"
  caching            = "ReadWrite"
}

# Create Managed Disk
resource "azurerm_managed_disk" "vm02_OsDisk_3" {
  name                 = "vm02_OsDisk_3"
  location             = azurerm_resource_group.test01.location
  resource_group_name  = azurerm_resource_group.test01.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 128
}

# Attach Disk to vm02
resource "azurerm_virtual_machine_data_disk_attachment" "vm02_OsDisk_3" {
  managed_disk_id    = azurerm_managed_disk.vm02_OsDisk_3.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm02.id
  lun                = "3"
  caching            = "ReadWrite"
}

# Create Managed Disk
resource "azurerm_managed_disk" "vm02_OsDisk_4" {
  name                 = "vm02_OsDisk_4"
  location             = azurerm_resource_group.test01.location
  resource_group_name  = azurerm_resource_group.test01.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 128
}

# Attach Disk to vm02
resource "azurerm_virtual_machine_data_disk_attachment" "vm02_OsDisk_4" {
  managed_disk_id    = azurerm_managed_disk.vm02_OsDisk_4.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm02.id
  lun                = "4"
  caching            = "ReadWrite"
}