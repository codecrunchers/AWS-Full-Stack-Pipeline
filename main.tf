module "vpc_pipeline" {
  source                     = "modules/vpc_module"
  name                       = "Pipeline-VPC"
  region                     = "${var.region}"
  key_name                   = "pipeline"
  cidr_block                 = "10.0.0.0/16"
  external_access_cidr_block = "0.0.0.0/0"
  private_subnet_cidr_blocks = "${var.private_subnet_cidr_blocks}"
  public_subnet_cidr_blocks  = "${var.public_subnet_cidr_blocks}"
  availability_zones         = "${var.availability_zones}"
  project                    = "CDPipeline"
}

module "vpn_instance" {
  source                = "modules/openvpn_terraform_module"
  vpc_id                = "${module.vpc_pipeline.id}"
  subnets               = "${module.vpc_pipeline.public_subnet_ids}"
  vpn_instance_details  = "${var.vpn_instance_details}"
  whitelist_cidr_blocks = ["37.228.251.43/32", "192.30.252.0/22", "185.199.108.0/22"] //Home,GitHUB*2
  environment           = "${var.environment}"
  dns_zone              = "${var.dns_zone}"
}

resource "aws_s3_bucket" "statefiles_for_app" {
  bucket = "statefiles-pipeline"
  acl    = "private"
}

module "pipeline_ecs" {
  source             = "modules/ecs_terraform_module"
  vpc_id             = "${module.vpc.id}"
  name               = "Pipeline-ECS-Cluster"
  public_subnets     = "${module.vpc_pipeline.public_subnet_cidr_blocks}"
  public_subnet_ids  = "${module.vpc_pipeline.public_subnet_ids}"
  private_subnets    = "${module.vpc_pipeline.private_subnet_cidr_blocks}"
  private_subnet_ids = "${module.vpc_pipeline.private_subnet_ids}"

  efs_mount_dns = "${module.pipeline_storage.efs_mount_dns}"
  environment   = "${var.environment}"
  dns_zone      = "${var.dns_zone}"

  whitelist_cidr_blocks = [
    "${formatlist("%s/32", module.vpc_pipeline.nat_gateway_ips)}",
    "37.228.251.43/32",
  ]

  low_port              = 8081
  high_port             = 9000
  vpc_id                = "${module.vpc_pipeline.id}"
  ecs_params            = "${var.ecs_params}"
  cloudwatch_log_handle = "${module.cloudwatch_host_container.cw_handle}"
  alb_target_groups     = ["${var.jenkins_pipeline_definition}"]
}

module "cloudwatch_host_container" {
  source      = "modules/cloudwatch_terraform_module"
  environment = "${var.environment}"
  name        = "${var.name}"

  app = {
    name = "ecs-pipeline-container"
  }
}

module "cloudwatch_jenkins" {
  source      = "modules/cloudwatch_terraform_module"
  environment = "${var.environment}"
  name        = "${var.name}"

  app = {
    name = "jenkins"
  }
}

module "pipeline_storage" {
  source             = "modules/filesystem_terraform_module"
  environment        = "${var.environment}"
  name               = "${var.name}"
  private_subnet_ids = "${module.vpc_pipeline.private_subnet_ids}"
  vpc_id             = "${module.vpc_pipeline.id}"
}

module "jenkins" {
  source              = "modules/ecs_service_terraform_module"
  environment         = "${var.environment}"
  name                = "${var.name}"
  pipeline_definition = "${var.jenkins_pipeline_definition}"
  docker_image_tag    = "jenkins/jenkins"

  ecs_details = {
    cluster_id                = "${module.pipeline_ecs.cluster_id}"
    iam_role                  = "${module.pipeline_ecs.iam_role}"
    cw_app_pipeline_log_group = "${var.name}/${var.environment}/jenkins"
  }

  region = "${var.region}"

  target_group_id = "${module.pipeline_ecs.target_group_id[0]}" #Jenkins
}

#Drop an ec2 instance in here

