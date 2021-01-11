# Create a resource group
resource "azurerm_resource_group" "test01" {
  name     = "atsushi.koizumi.test01"
  location = "East US"
  tags = {
    "Owner" = "koizumi",
    "Env"   = "test01"
  }
}
