variable "stack_details" {
  type = "map"
}

variable "consul_private_ip" {}
variable "cluster_name" {}

variable "ssh_key" {}

variable "ecs_params" {
  type = "map"
}

variable "dns_zone" {}

variable "efs_mount_dns" {}

variable "alb_target_groups" {
  type = "list"
}

#private_subnets private_subnet_ids public_subnets public_subnet_ids dns_zone name environment 

variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "eu-west-1"
}

variable "ecs_amis" {
  type = "map"

  default = {
    eu-west-1 = "ami-809f84e6"
    eu-west-2 = "ami-ff15039b"
  }
}

variable "whitelist_cidr_blocks" {
  type = "list"
}

variable "low_port" {}

variable "high_port" {}

variable "vpc_id" {}

variable "cloudwatch_log_handle" {}

variable "private_subnets" {
  type = "list"
}

variable "private_subnet_ids" {
  type = "list"
}

variable "public_subnet_ids" {
  type = "list"
}
