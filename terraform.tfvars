##Port

alb_whitelist_cidr_blocks = [
  "37.228.251.43/32", //Alan Home
  "86.44.120.159/32", //Joe Home
  "83.70.128.30/32",  //Office
  "52.51.124.44/32",  //AWS
  "52.212.38.150/32", //AWS
  "192.30.252.0/22",  //github
  "185.199.108.0/22", //GitHub
]

stack_details = {
  env         = "pre-prod"                             #Ideally Injected by Pipeline
  region      = "eu-west-1"
  stack_id    = "fedd1ace-6766-4c95-a1c4-72a8b3f56a4b"
  stack_name  = "Pipeline"
  stack_owner = "tech@planet9energy.com"
}

vpc_details_pipeline = {
  dns_suffix     = "planet9energy.io"
  num_az         = "3"
  vpc_cidr_block = "10.171.64.0/20"
}

subnet_cidrs_pipeline {
  vpc_cidr_block_amber = ["10.171.64.0/22", "10.171.68.0/22", "10.171.72.0/22"]
  vpc_cidr_block_green = ["10.171.76.0/25", "10.171.76.128/25", "10.171.77.0/25"]
  vpc_cidr_block_red   = ["10.171.77.128/25", "10.171.78.0/25", "10.171.78.128/25"]
}

vpn_instance_details = {
  ami      = "ami-015fbb78"
  size     = "t2.micro"
  key_name = "dselete-me-rds-verify"
}

vpn_whitelist_cidr_blocks = ["83.70.128.30/32"]

##EO Port
dns_zone = "p9e.io"

key_name = "dselete-me-rds-verify"

cidr_block = "10.0.0.0/16"

external_access_cidr_block = ["37.228.251.43/32", "83.70.128.30/32", "192.30.252.0/22", "185.199.108.0/22"] //Home,GitHUB*2

public_subnet_cidr_blocks = ["10.0.0.0/24", "10.0.2.0/24"]

private_subnet_cidr_blocks = ["10.0.1.0/24", "10.0.3.0/24"]

availability_zones = ["eu-west-1a", "eu-west-1b"]

qa_vpc = {
  public_subnet_cidr_blocks = ["10.0.0.0/24", "10.0.2.0/24"]

  private_subnet_cidr_blocks = ["10.0.1.0/24", "10.0.3.0/24"]

  availability_zones = ["eu-west-1a", "eu-west-1b"]
}

consul_definition = {
  docker_image_tag           = "492333042402.dkr.ecr.eu-west-1.amazonaws.com/tmp-pipeline/consul"
  name                       = "consul"
  context                    = "consul"
  host_port_to_expose        = "8500"                                                             #ALB
  container_port_to_expose   = "8500"                                                             #ALB
  instance_memory_allocation = "512"
  instance_count             = "1"
}

nexus_definition = {
  docker_image_tag           = "sonatype/nexus:oss"
  name                       = "nexus"
  context                    = "nexus"
  host_port_to_expose        = "8081"
  container_port_to_expose   = "8081"
  instance_memory_allocation = "1024"
  instance_count             = "1"
}

jenkins_pipeline_definition = {
  docker_image_tag           = "codecrunchers/jenkinsci:latest"
  name                       = "jenkins"
  context                    = "jenkins"
  host_port_to_expose        = "8080"
  container_port_to_expose   = "8080"
  instance_memory_allocation = "512"
  instance_count             = "1"
}

ecs_params = {
  min_instances     = 1
  max_instances     = 3
  desired_instances = 1
  ecs_name          = "pipeline"
  instance_type     = "t2.medium"
}
