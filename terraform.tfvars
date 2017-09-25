environment = "dev"

ecs_params = {
  min_instances     = 1
  max_instances     = 2
  desired_instances = 1
  ecs_name          = "pipeline"
  instance_type     = "t2.micro"
}

dns_zone = "paddle-planner.com"

name = "Pipeline"

project = "Pipeline"

region = "eu-west-1"

key_name = "pipeline"

cidr_block = "10.0.0.0/16"

external_access_cidr_block = "0.0.0.0/0"

public_subnet_cidr_blocks = ["10.0.0.0/24", "10.0.2.0/24"]

private_subnet_cidr_blocks = ["10.0.1.0/24", "10.0.3.0/24"]

availability_zones = ["eu-west-1a", "eu-west-1b"]

vpn_instance_details = {
  ami      = "ami-015fbb78"
  size     = "t2.micro"
  key_name = "pipeline"
}

jenkins_pipeline_definition = {
  docker_image_tag           = "jenkins/jenkins:lts"
  name                       = "jenkins"
  host_port_to_expose        = "8080"
  container_port_to_expose   = "8080"
  instance_memory_allocation = "2048"
  instance_count             = "1"
}
