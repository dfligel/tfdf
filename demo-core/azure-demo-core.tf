terraform {
	  backend "local" {
			path = "./terraform.tfstate"
	  }
}

output "rgname" {
	value =  "${azurerm_resource_group.rg1.name}"
}

output "sub_trans_data_id" {
	value =  "${azurerm_subnet.trans_data.id}"
}

output "sub_trans_control_id" {
	value =  "${azurerm_subnet.trans_control.id}"
}

resource "azurerm_resource_group" "rg1" {
  name     = "${var.rg1}"
  location = "${var.region}"
}

resource "azurerm_virtual_network" "transit" {
  name                = "${var.vnet_transit}"
  address_space       = ["${var.vnet_transit_cidr}"]
  location            = "${azurerm_resource_group.rg1.location}"
  resource_group_name = "${azurerm_resource_group.rg1.name}"
}

resource "azurerm_virtual_network" "services1" {
  name                = "${var.vnet_services1}"
  address_space       = ["${var.vnet_services1_cidr}"]
  location            = "${azurerm_resource_group.rg1.location}"
  resource_group_name = "${azurerm_resource_group.rg1.name}"
}

resource "azurerm_virtual_network" "services2" {
  name                = "${var.vnet_services2}"
  address_space       = ["${var.vnet_services2_cidr}"]
  location            = "${azurerm_resource_group.rg1.location}"
  resource_group_name = "${azurerm_resource_group.rg1.name}"
}

resource "azurerm_subnet" "trans_data" {
  name                 = "${var.vnet_transit}_${var.sub_trans_data}"
  resource_group_name  = "${azurerm_resource_group.rg1.name}"
  virtual_network_name = "${azurerm_virtual_network.transit.name}"
  address_prefix       = "${var.sub_trans_data_cidr}"
}

resource "azurerm_subnet" "trans_control" {
  name                 = "${var.vnet_transit}_${var.sub_trans_ctrl}"
  resource_group_name  = "${azurerm_resource_group.rg1.name}"
  virtual_network_name = "${azurerm_virtual_network.transit.name}"
  address_prefix       = "${var.sub_trans_ctrl_cidr}"
}

resource "azurerm_subnet" "serv1_front" {
  name                 = "${var.vnet_services1}_${var.sub_serv1_front}"
  resource_group_name  = "${azurerm_resource_group.rg1.name}"
  virtual_network_name = "${azurerm_virtual_network.services1.name}"
  address_prefix       = "${var.sub_serv1_front_cidr}"
}

resource "azurerm_subnet" "serv1_back" {
  name                 = "${var.vnet_services1}_${var.sub_serv1_back}"
  resource_group_name  = "${azurerm_resource_group.rg1.name}"
  virtual_network_name = "${azurerm_virtual_network.services1.name}"
  address_prefix       = "${var.sub_serv1_back_cidr}"
}

resource "azurerm_subnet" "serv2_front" {
  name                 = "${var.vnet_services2}_${var.sub_serv2_front}"
  resource_group_name  = "${azurerm_resource_group.rg1.name}"
  virtual_network_name = "${azurerm_virtual_network.services2.name}"
  address_prefix       = "${var.sub_serv2_front_cidr}"
}

resource "azurerm_subnet" "serv2_back" {
  name                 = "${var.vnet_services2}_${var.sub_serv2_back}"
  resource_group_name  = "${azurerm_resource_group.rg1.name}"
  virtual_network_name = "${azurerm_virtual_network.services2.name}"
  address_prefix       = "${var.sub_serv2_back_cidr}"
}

resource "azurerm_virtual_network_peering" "trans_svc1" {
  name                      = "${var.peer_trans_svc1}"
  resource_group_name       = "${azurerm_resource_group.rg1.name}"
  virtual_network_name      = "${azurerm_virtual_network.transit.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.services1.id}"
	allow_virtual_network_access = "true"
	allow_forwarded_traffic      = "true"
}

resource "azurerm_virtual_network_peering" "svc1_trans" {
  name                      = "${var.peer_svc1_trans}"
  resource_group_name       = "${azurerm_resource_group.rg1.name}"
  virtual_network_name      = "${azurerm_virtual_network.services1.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.transit.id}"
	allow_virtual_network_access = "true"
}

resource "azurerm_virtual_network_peering" "trans_svc2" {
  name                      = "${var.peer_trans_svc2}"
  resource_group_name       = "${azurerm_resource_group.rg1.name}"
  virtual_network_name      = "${azurerm_virtual_network.transit.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.services2.id}"
	allow_virtual_network_access = "true"
	allow_forwarded_traffic      = "true"
}

resource "azurerm_virtual_network_peering" "svc2_trans" {
  name                      = "${var.peer_svc2_trans}"
  resource_group_name       = "${azurerm_resource_group.rg1.name}"
  virtual_network_name      = "${azurerm_virtual_network.services2.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.transit.id}"
	allow_virtual_network_access = "true"
}

resource "azurerm_virtual_network_peering" "svc1_svc2" {
  name                      = "${var.peer_svc1_svc2}"
  resource_group_name       = "${azurerm_resource_group.rg1.name}"
  virtual_network_name      = "${azurerm_virtual_network.services1.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.services2.id}"
	allow_virtual_network_access = "true"
}

resource "azurerm_virtual_network_peering" "svc2_svc1" {
  name                      = "${var.peer_svc2_svc1}"
  resource_group_name       = "${azurerm_resource_group.rg1.name}"
  virtual_network_name      = "${azurerm_virtual_network.services2.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.services1.id}"
	allow_virtual_network_access = "true"
}
