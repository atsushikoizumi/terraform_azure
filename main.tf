# Create a resource group
resource "azurerm_resource_group" "test01" {
  name     = "atsushi.koizumi.test01"
  location = "East US"
  tags = {
    "Owner" = "koizumi",
    "Env"   = "test01"
  }
}

# Policy assignment
resource "azurerm_policy_assignment" "Allowed_locations" {
  name                 = "Allowed-locations"
  scope                = azurerm_resource_group.test01.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
  description          = "This policy enables you to restrict the locations your organization can specify when deploying resources. Use to enforce your geo-compliance requirements. Excludes resource groups, Microsoft.AzureActiveDirectory/b2cDirectories, and resources that use the 'global' region."
  display_name         = "Allowed locations"
  identity {
    type = "SystemAssigned"
  }
  location   = "eastus"
  parameters = <<PARAMETERS
    {
      "listOfAllowedLocations": {
        "value": [ "East US","East US 2" ]
      }
    }
  PARAMETERS
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "test01" {
  name                = "test01"
  resource_group_name = azurerm_resource_group.test01.name
  location            = azurerm_resource_group.test01.location
  address_space       = ["10.0.0.0/16"]
  tags = {
    "Owner" = "koizumi",
    "Env"   = "test01"
  }
}

