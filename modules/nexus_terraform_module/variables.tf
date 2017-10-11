variable "consul_private_ip" {}

variable "name" {}

variable "environment" {}

variable "nexus_definition" {
  type = "map"
}

variable "ecs_details" {
  type = "map"
}

variable "region" {}

variable "target_group_id" {}

variable "docker_image_tag" {}
