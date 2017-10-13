#Port

variable "alb_whitelist_cidr_blocks" {
  type = "list"
}

variable "subnet_cidrs_pipeline" {
  type = "map"
}

variable "vpc_details_pipeline" {
  type = "map"
}

variable "stack_details" {
  type = "map"
}

variable "vpn_instance_details" {
  type = "map"
}

variable "vpn_whitelist_cidr_blocks" {
  type = "list"
}

variable "ecs_params" {
  type = "map"
}

# Eo Port

#variable "name" {
#  default = "Default"
#}

variable "project" {
  default = "Unknown"
}

#variable "environment" {
#  default = "dev"
#}

variable "region" {
  default = "eu-west-1"
}

variable "key_name" {}

variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "external_access_cidr_block" {
  type = "list"
}

#variable "public_subnet_cidr_blocks" {
#  type    = "list"
#  default = ["10.0.0.0/24", "10.0.2.0/24"]
#}

#variable "private_subnet_cidr_blocks" {
#  type    = "list"
#  default = ["10.0.1.0/24", "10.0.3.0/24"]
#}

#variable "availability_zones" {
#  type = "list"
#}

variable "dns_zone" {}

variable "jenkins_pipeline_definition" {
  type = "map"
}

variable "nexus_definition" {
  type = "map"
}

variable "consul_definition" {
  type = "map"
}
