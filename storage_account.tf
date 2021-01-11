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