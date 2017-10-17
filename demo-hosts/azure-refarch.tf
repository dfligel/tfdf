data "terraform_remote_state" "foo" {
	  backend = "local"
		  config {
				path = "../demo-core/terraform.tfstate"
			}
}

resource "azurerm_network_interface" "test" {
  name                = "fg1nic1"
  location            = "UK South"
	resource_group_name = "${data.terraform_remote_state.foo.rgname}"
  enable_ip_forwarding = "true"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${data.terraform_remote_state.foo.sub_trans_data_id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.pip.id}"
  }
}

resource "azurerm_network_interface" "test2" {
  name                = "fg1nic2"
  location            = "UK South"
  resource_group_name = "${data.terraform_remote_state.foo.rgname}"
  enable_ip_forwarding = "true"

  ip_configuration {
    name                          = "testconfiguration2"
    subnet_id                     = "${data.terraform_remote_state.foo.sub_trans_control_id}"
    private_ip_address_allocation = "dynamic"
    }
}

resource "azurerm_public_ip" "pip" {
  name                         = "FG1PIP2"
  location                     = "UK South"
  resource_group_name          = "${data.terraform_remote_state.foo.rgname}"
  public_ip_address_allocation = "Dynamic"
}

resource "azurerm_managed_disk" "test" {
  name                 = "datadisk_existing"
  location             = "UK South"
  resource_group_name  = "${data.terraform_remote_state.foo.rgname}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "10"
}

resource "azurerm_virtual_machine" "test" {
  name                  = "transFG1"
  location              = "UK South"
  resource_group_name   = "${data.terraform_remote_state.foo.rgname}"
  network_interface_ids = ["${azurerm_network_interface.test.id}","${azurerm_network_interface.test2.id}"]
  primary_network_interface_id = "${azurerm_network_interface.test.id}"
  vm_size               = "Standard_DS2_v2"

plan {
    name = "fortinet_fg-vm_payg"
    product = "fortinet_fortigate-vm_v5"
    publisher = "fortinet"
      }

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

storage_image_reference {
    publisher = "fortinet"
    offer     = "fortinet_fortigate-vm_v5"
    sku       = "fortinet_fg-vm_payg"
    version   = "5.6.2"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  # Optional data disks
  storage_data_disk {
    name              = "datadisk_new"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "10"
  }

  storage_data_disk {
    name            = "${azurerm_managed_disk.test.name}"
    managed_disk_id = "${azurerm_managed_disk.test.id}"
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = "${azurerm_managed_disk.test.disk_size_gb}"
  }

  os_profile {
    computer_name  = "TRANSFG1"
    admin_username = "fgadmin"
    admin_password = "Fortinet123!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
    environment = "staging"
  }
}
