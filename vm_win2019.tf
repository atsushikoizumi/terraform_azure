# Create Virtual Machine
resource "azurerm_windows_virtual_machine" "vm01" {
  name                = "vm01"
  resource_group_name = azurerm_resource_group.test01.name
  location            = azurerm_resource_group.test01.location
  size                = "Standard_B2ms"
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

