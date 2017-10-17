data "terraform_remote_state" "demo-core" {
	  backend = "local"
		  config {
				path = "../demo-core/terraform.tfstate"
			}
}

resource "azurerm_network_interface" "fg1_nic1" {
  name                = "${var.fg1_nic1_name}"
  location            = "${data.terraform_remote_state.demo-core.region}"
	resource_group_name = "${data.terraform_remote_state.demo-core.rgname}"
  enable_ip_forwarding = "true"

  ip_configuration {
    name                          = "${var.fg1_nic1_ip_name}"
		subnet_id                     = "${data.terraform_remote_state.demo-core.sub_trans_data_id}"
    private_ip_address_allocation = "${var.fg1_nic1_ip_addr}"
    public_ip_address_id          = "${azurerm_public_ip.pip1.id}"
  }
}

resource "azurerm_network_interface" "fg1_nic2" {
	name                = "${var.fg1_nic2_name}"
  location            = "${data.terraform_remote_state.demo-core.region}"
  resource_group_name = "${data.terraform_remote_state.demo-core.rgname}"
  enable_ip_forwarding = "true"

  ip_configuration {
    name                          = "${var.fg1_nic2_ip_name}"
    subnet_id                     = "${data.terraform_remote_state.demo-core.sub_trans_control_id}"
    private_ip_address_allocation = "dynamic"
    }
}

resource "azurerm_network_interface" "svc1_ubu1_nic1" {
	name                = "${var.svc1_ubu1_nic1_name}"
  location            = "${data.terraform_remote_state.demo-core.region}"
  resource_group_name = "${data.terraform_remote_state.demo-core.rgname}"
  enable_ip_forwarding = "false"

  ip_configuration {
    name                          = "${var.svc1_ubu1_nic1_ip_name}"
    subnet_id                     = "${data.terraform_remote_state.demo-core.sub_serv1_front_id}"
    private_ip_address_allocation = "dynamic"
    }
}

resource "azurerm_public_ip" "pip1" {
  name                         = "${var.fg1_pip_name}"
  location                     = "${data.terraform_remote_state.demo-core.region}"
  resource_group_name          = "${data.terraform_remote_state.demo-core.rgname}"
  public_ip_address_allocation = "dynamic"
}

resource "azurerm_managed_disk" "fg1_storage" {
  name                 = "${var.fg1_disk2_name}"
  location             = "${data.terraform_remote_state.demo-core.region}"
  resource_group_name  = "${data.terraform_remote_state.demo-core.rgname}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "${var.fg1_disk2_size}"
}

resource "azurerm_managed_disk" "svc1_ubu1_storage" {
  name                 = "${var.svc1_ubu1_disk2_name}"
  location             = "${data.terraform_remote_state.demo-core.region}"
  resource_group_name  = "${data.terraform_remote_state.demo-core.rgname}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "${var.svc1_ubu1_disk2_size}"
}

resource "azurerm_virtual_machine" "fg1" {
  name                  = "${var.fg1_vm_name}"
  location              = "${data.terraform_remote_state.demo-core.region}"
  resource_group_name   = "${data.terraform_remote_state.demo-core.rgname}"
  network_interface_ids = ["${azurerm_network_interface.fg1_nic1.id}","${azurerm_network_interface.fg1_nic2.id}"]
  primary_network_interface_id = "${azurerm_network_interface.fg1_nic1.id}"
  vm_size               = "${var.fg1_vm_size}"

plan {
    name = "${var.fg1_vm_plan_name}"
    product = "${var.fg1_vm_plan_product}"
    publisher = "${var.fg1_vm_plan_publisher}"
      }

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

	# provisioner "remote-exec" {
	# 	inline = [
	# 		"config system global",
	# 		"set admintimeout 60",
	# 		"end",
	# 	]

		# connection {
		# 	type = "ssh"
		# 	host = "${azurerm_public_ip.pip1.ip_address}"
		# 	user = "${var.fg1_vm_os_user}"
		# 	password = "${var.fg1_vm_os_pass}"
	# }	
# }
storage_image_reference {
    publisher = "${var.fg1_vm_image_publisher}"
    offer     = "${var.fg1_vm_image_offer}"
    sku       = "${var.fg1_vm_image_sku}"
    version   = "${var.fg1_vm_image_version}"
  }

  storage_os_disk {
    name              = "${var.fg1_vm_osdisk_name}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  # # Optional data disks
  #  storage_data_disk {
  #   name              = "${fg1_vm_disk2_name}"
  #   managed_disk_type = "Standard_LRS"
  #   create_option     = "Empty"
  #   lun               = 0
  #   disk_size_gb      = "${fg1_vm_disk2_size}"
  # }

  storage_data_disk {
    name            = "${azurerm_managed_disk.fg1_storage.name}"
    managed_disk_id = "${azurerm_managed_disk.fg1_storage.id}"
    create_option   = "Attach"
    lun             = 1
   # disk_size_gb    = "${azurerm_managed_disk.fg1_storage.disk_size_gb}"
    disk_size_gb    = "${var.fg1_disk2_size}"
  }

  os_profile {
    computer_name  = "${var.fg1_vm_os_name}"
    admin_username = "${var.fg1_vm_os_user}"
    admin_password = "${var.fg1_vm_os_pass}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
    environment = "staging"
  }
}

resource "azurerm_virtual_machine" "svc1_ubu1" {
  name                  = "${var.svc1_ubu1_vm_name}"
  location              = "${data.terraform_remote_state.demo-core.region}"
  resource_group_name   = "${data.terraform_remote_state.demo-core.rgname}"
  network_interface_ids = ["${azurerm_network_interface.svc1_ubu1_nic1.id}"]
  vm_size               = "${var.svc1_ubu1_vm_size}"

# plan {
#     name = "${var.svc1_ubu1_vm_plan_name}"
    # product = "${var.svc1_ubu1_vm_plan_product}"
    # publisher = "${var.svc1_ubu1_vm_plan_publisher}"
      # }

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

storage_image_reference {
    publisher = "${var.svc1_ubu1_vm_image_publisher}"
    offer     = "${var.svc1_ubu1_vm_image_offer}"
    sku       = "${var.svc1_ubu1_vm_image_sku}"
    version   = "${var.svc1_ubu1_vm_image_version}"
  }

  storage_os_disk {
    name              = "${var.svc1_ubu1_vm_osdisk_name}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name            = "${azurerm_managed_disk.svc1_ubu1_storage.name}"
    managed_disk_id = "${azurerm_managed_disk.svc1_ubu1_storage.id}"
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = "${azurerm_managed_disk.svc1_ubu1_storage.disk_size_gb}"
  }

  os_profile {
    computer_name  = "${var.svc1_ubu1_vm_os_name}"
    admin_username = "${var.svc1_ubu1_vm_os_user}"
    admin_password = "${var.svc1_ubu1_vm_os_pass}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
    environment = "staging"
  }
}

## Route Tables - UDR

resource "azurerm_route_table" "svc1_front_udr" {
	name						= "${var.svc1_front_udr_name}"
	location				= "${data.terraform_remote_state.demo-core.region}"
	resource_group_name = "${data.terraform_remote_state.demo-core.rgname}"

	route {
		name							= "${var.svc1_front_udr_r1}"
		address_prefix		= "${var.svc1_front_udr_prefix}"
		next_hop_type			= "${var.svc1_front_udr_nh_type}"
		next_hop_in_ip_address			= "${azurerm_network_interface.fg1_nic1.private_ip_address}"
	}
}
