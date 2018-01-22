variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

variable "resource_group_name" {}

variable "my_resource_prefix" {
    type = "string"
    default = "test"
}

variable "node_count" {
    type = "string"
    default = "1"
}

# Your IP if you want to whitelist a specific IP for inbound
variable "allowed_ip" {
    type = "string"
    default = "*"
}


variable "admin_username" {}
variable "admin_password" {}

variable "image_publisher" {}
variable "image_offer" {}
variable "image_sku" {}

variable "vm_size" {}
variable "region" {}
