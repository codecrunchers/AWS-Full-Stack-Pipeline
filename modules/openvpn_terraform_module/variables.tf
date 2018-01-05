variable "stack_details" {
  type = "map"
}

variable "vpc_id" {}

variable "subnets" {
  type = "list"
}

variable "whitelist_cidr_blocks" {
  type = "list"
}

variable "vpn_instance_details" {
  type = "map"
}

variable "dns_zone" {}
