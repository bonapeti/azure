provider "azurerm" {}

resource "azurerm_resource_group" "terraform_eval" {
  name     = "terraform_eval"
  location = "West Europe"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "terraform_eval_network" {
  name                = "terraform_eval_network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.terraform_eval.location}"
  resource_group_name = "${azurerm_resource_group.terraform_eval.name}"

  subnet {
    name           = "backend"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "frontend"
    address_prefix = "10.0.2.0/24"
  }

}
