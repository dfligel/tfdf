# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "tfrefarch1"
  location = "UK South"
}

resource "azurerm_virtual_network" "network" {
  name                = "tfrefarchtest"
  address_space       = ["10.99.0.0/16"]
  location            = "UK South"
  resource_group_name = "${azurerm_resource_group.rg.name}"

    subnet {
    name           = "subnet1"
    address_prefix = "10.99.99.0/24"
  }
}

