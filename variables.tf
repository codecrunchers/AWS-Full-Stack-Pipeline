variable "dns_zone" {}

variable "key_name" {
  #  default = "my-test-key"
}

variable "stack_details" {
  type = "map"

  default = {
    stack_id   = "e02c0de3-368d-4531-8ce8-b7d2cf2e34f8"
    stack_name = "POC"
    env        = "POC"
  }
}

variable "vpn_instance_details" {
  type = "map"
}

variable "ecs_params" {
  type = "map"

  default = {
    min_instances     = 1
    max_instances     = 3
    desired_instances = 1
    ecs_name          = "JenkinsDelivery"
    instance_type     = "t2.medium"
  }
}

variable "region" {
  default = "eu-west-1"
}

# Pipeline CIDR Stuff
variable "pipeline_cidr_block" {
  default = "10.171.0.0/16"
}

variable "pipeline_external_access_cidr_block" {
  type = "list"
}

variable "pipeline_public_subnet_cidr_blocks" {
  type    = "list"
  default = ["10.171.77.128/25", "10.171.78.0/25"]
}

variable "pipeline_private_subnet_cidr_blocks" {
  type    = "list"
  default = ["10.171.76.0/25", "10.171.76.128/25"]
}

variable "pipeline_availability_zones" {
  type    = "list"
  default = ["eu-west-1a", "eu-west-1b"]
}

variable "jenkins_pipeline_definition" {
  type = "map"
}

variable "nexus_definition" {
  type = "map"
}
