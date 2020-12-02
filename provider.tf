# tfstate on storage account
terraform {
  required_version = "= 0.13.5"

  backend "azurerm" {
    resource_group_name  = "atsushi.koizumi.data"
    storage_account_name = "terraform0tfstate"
    container_name       = "tfstate"
    key                  = "test01.tfstate"
  }
}

# provider azurerm
provider "azurerm" {
  version         = "=2.38.0"
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

  features {}
}
