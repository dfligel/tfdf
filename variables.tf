variable "resource_group" {
  description = "The name of the resource group in which the virtual networks are created"
  default     = "tfrefarch1"
}

variable "vnet_transit" {
  description = "NAme of the first VNET (transit)"
  default = "TRANSIT"
}
