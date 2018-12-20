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

resource "azurerm_public_ip" "frontend_pip" {
  name                         = "frontend_pip"
  location                     = "${azurerm_resource_group.terraform_eval.location}"
  resource_group_name          = "${azurerm_resource_group.terraform_eval.name}"
  public_ip_address_allocation = "Dynamic"
  idle_timeout_in_minutes      = 30

}


resource "azurerm_network_interface" "terraform_eval_frontend_if" {
  name                = "frontend_if"
  location            = "${azurerm_resource_group.terraform_eval.location}"
  resource_group_name = "${azurerm_resource_group.terraform_eval.name}"

  ip_configuration {
    name                          = "frontend_configuration"
    subnet_id                     = "${azurerm_subnet.frontend.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id 	  = "${azurerm_public_ip.frontend_pip.id}"
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

resource "azurerm_virtual_machine" "dwe-bonapeti-lf001" {
	name = "dwe-bonapeti-lf0001"
	location            = "${azurerm_resource_group.terraform_eval.location}"
        resource_group_name = "${azurerm_resource_group.terraform_eval.name}"
	network_interface_ids = ["${azurerm_network_interface.terraform_eval_frontend_if.id}"]
	vm_size	= "Standard_B1s"

	os_profile {
    		computer_name  = "dwe-bonapeti-lf001"
    		admin_username = "bonapet"
    		admin_password = "Gikszer!"
  	}

	storage_image_reference {
    		publisher = "OpenLogic"
		offer = "CentOS"
    		sku       = "7.5"
    		version   = "latest"
  	}

	storage_os_disk {
    		name              = "frontend_osdisk"
    		caching           = "ReadWrite"
    		create_option     = "FromImage"
    		managed_disk_type = "Standard_LRS"
  	}
	
	os_profile_linux_config {
    		disable_password_authentication = false
  	}
}

resource "azurerm_virtual_machine" "dwe-bonapeti-lb001" {
        name = "dwe-bonapeti-lb0001"
        location            = "${azurerm_resource_group.terraform_eval.location}"
        resource_group_name = "${azurerm_resource_group.terraform_eval.name}"
        network_interface_ids = ["${azurerm_network_interface.terraform_eval_backend_if.id}"]
        vm_size = "Standard_B1s"

        os_profile {
                computer_name  = "dwe-bonapeti-lb001"
                admin_username = "bonapet"
                admin_password = "Gikszer!"
        }

        storage_image_reference {
                publisher = "OpenLogic"
                offer = "CentOS"
                sku       = "7.5"
                version   = "latest"
        }

        storage_os_disk {
                name              = "backend_osdisk"
                caching           = "ReadWrite"
                create_option     = "FromImage"
                managed_disk_type = "Standard_LRS"
        }

        os_profile_linux_config {
                disable_password_authentication = false
        }
}
