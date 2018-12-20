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

}

resource "azurerm_subnet" "frontend" {
	name                 = "frontend"
  	resource_group_name  = "${azurerm_resource_group.terraform_eval.name}"
  	virtual_network_name = "${azurerm_virtual_network.terraform_eval_network.name}"
  	address_prefix       = "10.0.2.0/24"
}

resource "azurerm_subnet" "backend" {
        name                 = "backend"
        resource_group_name  = "${azurerm_resource_group.terraform_eval.name}"
        virtual_network_name = "${azurerm_virtual_network.terraform_eval_network.name}"
        address_prefix       = "10.0.1.0/24"
}


resource "azurerm_network_interface" "terraform_eval_frontend_if" {
  name                = "frontend_if"
  location            = "${azurerm_resource_group.terraform_eval.location}"
  resource_group_name = "${azurerm_resource_group.terraform_eval.name}"

  ip_configuration {
    name                          = "frontend_configuration"
    subnet_id                     = "${azurerm_subnet.frontend.id}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_network_interface" "terraform_eval_backend_if" {
  name                = "backend_if"
  location            = "${azurerm_resource_group.terraform_eval.location}"
  resource_group_name = "${azurerm_resource_group.terraform_eval.name}"

  ip_configuration {
    name                          = "backend_configuration"
    subnet_id                     = "${azurerm_subnet.backend.id}"
    private_ip_address_allocation = "dynamic"
  }
}

