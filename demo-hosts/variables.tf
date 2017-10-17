# Fortigates
variable "fg1_nic1_name" {}
variable "fg1_nic1_ip_name" {}
variable "fg1_nic1_ip_addr" {}
variable "fg1_pip_name" {}
variable "fg1_nic2_name" {}
variable "fg1_nic2_ip_name" {}
variable "fg1_nic2_ip_addr" {}
variable "fg1_disk2_name" {}
variable "fg1_disk2_size" {}
variable "fg1_vm_name" {}
variable "fg1_vm_size" {}
variable "fg1_vm_plan_name" {}
variable "fg1_vm_plan_product" {}
variable "fg1_vm_plan_publisher" {}
variable "fg1_vm_image_publisher" {}
variable "fg1_vm_image_offer" {}
variable "fg1_vm_image_sku" {}
variable "fg1_vm_image_version" {}
variable "fg1_vm_osdisk_name" {}
variable "fg1_vm_disk2_name" {}
variable "fg1_vm_disk2_size" {}
variable "fg1_vm_os_name" {}
variable "fg1_vm_os_user" {}
variable "fg1_vm_os_pass" {}

# Ubu Boxes
variable "svc1_ubu1_nic1_name" {}
variable "svc1_ubu1_nic1_ip_name" {}
variable "svc1_ubu1_nic1_ip_addr" {}
variable "svc1_ubu1_disk2_name" {}
variable "svc1_ubu1_disk2_size" {}
variable "svc1_ubu1_vm_name" {}
variable "svc1_ubu1_vm_size" {}
variable "svc1_ubu1_vm_plan_name" {}
variable "svc1_ubu1_vm_plan_product" {}
variable "svc1_ubu1_vm_plan_publisher" {}
variable "svc1_ubu1_vm_image_publisher" {}
variable "svc1_ubu1_vm_image_offer" {}
variable "svc1_ubu1_vm_image_sku" {}
variable "svc1_ubu1_vm_image_version" {}
variable "svc1_ubu1_vm_osdisk_name" {}
variable "svc1_ubu1_vm_disk2_name" {}
variable "svc1_ubu1_vm_disk2_size" {}
variable "svc1_ubu1_vm_os_name" {}
variable "svc1_ubu1_vm_os_user" {}
variable "svc1_ubu1_vm_os_pass" {}

# Route Tables
variable "svc1_front_udr_name" {}

# Routes
variable "svc1_front_udr_r1" {}
variable "svc1_front_udr_prefix" {}
variable "svc1_front_udr_nh_type" {}
