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
  location = "eastus"
  parameters = <<PARAMETERS
    {
      "listOfAllowedLocations": {
        "value": [ "East US","East US 2" ]
      }
    }
  PARAMETERS
}

resource "azurerm_policy_assignment" "inherit_tag_from_rg" {
  name                 = "Inherit-tag-from-resourcegroup"
  scope                = azurerm_resource_group.test01.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/cd3aa116-8754-49c9-a813-ad46512ece54"
  description          = "Adds or replaces the specified tag and value from the parent resource group when any resource is created or updated. Existing resources can be remediated by triggering a remediation task."
  display_name         = "Inherit a tag from the resource group"
  identity {
      type = "SystemAssigned"
  }
  location = "eastus"
  parameters = <<PARAMETERS
    {
      "tagName": {
        "value": "Owner"
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
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "test02" {
  name                = "test02"
  resource_group_name = azurerm_resource_group.test01.name
  location            = "East US 2"
  address_space       = ["10.0.0.0/16"]
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "test03" {
  name                = "test03"
  resource_group_name = azurerm_resource_group.test01.name
  location            = "West US 2"
  address_space       = ["10.0.0.0/16"]
}