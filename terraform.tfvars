environment = "tmp"

dns_zone = "cd-pipeline.io"

name = "Pipeline"

project = "Pipeline"

region = "eu-west-1"

key_name = "pipeline-ecs"

cidr_block = "10.0.0.0/16"

external_access_cidr_block = ["37.228.251.43/32", "83.70.128.30/32", "192.30.252.0/22", "185.199.108.0/22"] //Home,GitHUB*2

public_subnet_cidr_blocks = ["10.0.0.0/24", "10.0.2.0/24"]

private_subnet_cidr_blocks = ["10.0.1.0/24", "10.0.3.0/24"]

availability_zones = ["eu-west-1a", "eu-west-1b"]

vpn_instance_details = {
  ami      = "ami-015fbb78"
  size     = "t2.micro"
  key_name = "pipeline-ecs"
}

consul_definition = {
  docker_image_tag           = "492333042402.dkr.ecr.eu-west-1.amazonaws.com/tmp-pipeline/consul"
  name                       = "consul"
  context                    = "consul"
  host_port_to_expose        = "8500"                                                             #ALB
  container_port_to_expose   = "8500"                                                             #ALB
  instance_memory_allocation = "512"
  instance_count             = "0"
}

registrator_definition = {
  docker_image_tag           = "492333042402.dkr.ecr.eu-west-1.amazonaws.com/tmp-pipeline/registrator"
  name                       = "registrator"
  context                    = "registrator"
  host_port_to_expose        = ""                                                                      #Don't
  container_port_to_expose   = ""
  instance_memory_allocation = "512"
  instance_count             = "0"
}

jenkins_pipeline_definition = {
  docker_image_tag           = "492333042402.dkr.ecr.eu-west-1.amazonaws.com/tmp-pipeline/jenkins"
  name                       = "jenkins"
  context                    = "jenkins"
  host_port_to_expose        = "8080"
  container_port_to_expose   = "8080"
  instance_memory_allocation = "512"
  instance_count             = "1"
}

jenkins_pipeline_slave_definition = {
  docker_image_tag           = "492333042402.dkr.ecr.eu-west-1.amazonaws.com/tmp-pipeline/jenkinsslave"
  name                       = "jenkins-slave"
  context                    = "jenkins-slave"
  host_port_to_expose        = ""
  container_port_to_expose   = ""
  instance_memory_allocation = "128"
  instance_count             = "0"
}

ecs_params = {
  min_instances     = 1
  max_instances     = 3
  desired_instances = 1
  ecs_name          = "pipeline"
  instance_type     = "t2.medium"
}
