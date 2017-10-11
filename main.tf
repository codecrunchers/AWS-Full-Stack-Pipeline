module "vpc_pipeline" {
  source                     = "modules/vpc_module"
  name                       = "Pipeline-VPC"                      #TODO Var
  region                     = "${var.region}"
  key_name                   = "${aws_key_pair.deployer.key_name}"
  cidr_block                 = "${var.cidr_block}"
  external_access_cidr_block = "${var.external_access_cidr_block}"
  private_subnet_cidr_blocks = "${var.private_subnet_cidr_blocks}"
  public_subnet_cidr_blocks  = "${var.public_subnet_cidr_blocks}"
  availability_zones         = "${var.availability_zones}"
  project                    = "CDPipeline"                        #TODO Didn't use consistently along with name
  iam_ecs                    = "${module.pipeline_ecs.iam_ecs}"
  dns_zone_name              = "${var.dns_zone}"
}

module "vpn_instance" {
  source                = "modules/openvpn_terraform_module"
  vpc_id                = "${module.vpc_pipeline.id}"
  subnets               = "${module.vpc_pipeline.public_subnet_ids}"
  vpn_instance_details  = "${var.vpn_instance_details}"
  whitelist_cidr_blocks = "${var.external_access_cidr_block}"
  environment           = "${var.environment}"
  dns_zone              = "${var.dns_zone}"
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
  cluster_name  = "${var.environment}-Pipeline-ECS-Cluster"  #TODO: mmm mmm
  ssh_key       = "${aws_key_pair.deployer.key_name}"

  whitelist_cidr_blocks = [
    "${formatlist("%s/32", module.vpc_pipeline.nat_gateway_ips)}",
    "37.228.251.43/32",
    "83.70.128.30/32",
  ] #TODO Vars

  low_port              = 8080                                                                                  #TODO mmmm
  high_port             = 9000
  vpc_id                = "${module.vpc_pipeline.id}"
  ecs_params            = "${var.ecs_params}"
  cloudwatch_log_handle = "${module.cloudwatch_pipeline.cw_handle[0]}"
  alb_target_groups     = "${list(var.jenkins_pipeline_definition,var.consul_definition,var.nexus_definition)}"
  consul_private_ip     = "${module.vpc_pipeline.consul_private_ip}"
}

module "cloudwatch_pipeline" {
  source      = "modules/cloudwatch_terraform_module"
  environment = "${var.environment}"
  name        = "${var.name}"

  groups = [
    {
      name              = "ecs-pipeline-container"
      retention_in_days = 14
    },
    {
      name              = "jenkins"
      retention_in_days = 14
    },
    {
      name              = "consul"
      retention_in_days = 14
    },
    {
      name              = "nexus"
      retention_in_days = 14
    },
  ]
}

module "pipeline_storage" {
  source             = "modules/filesystem_terraform_module"
  environment        = "${var.environment}"
  name               = "${var.name}"
  private_subnet_ids = "${module.vpc_pipeline.private_subnet_ids}"
  vpc_id             = "${module.vpc_pipeline.id}"
}

#Consul Agent for Containers
module "consul" {
  source            = "modules/consul_terraform_module"
  environment       = "${var.environment}"
  name              = "${var.name}"
  consul_definition = "${var.consul_definition}"
  docker_image_tag  = "${var.consul_definition["docker_image_tag"]}"
  consul_private_ip = "${module.vpc_pipeline.consul_private_ip}"

  ecs_details = {
    cluster_id                = "${module.pipeline_ecs.cluster_id}"
    iam_role                  = "${module.pipeline_ecs.iam_role}"
    cw_app_pipeline_log_group = "${var.name}/${var.environment}/consul"
  }

  region = "${var.region}"

  target_group_id = "${module.pipeline_ecs.target_group_id[1]}" #Consul
}

module "nexus" {
  source              = "modules/jenkins_terraform_module"
  environment         = "${var.environment}"
  name                = "${var.name}"
  pipeline_definition = "${var.nexus_definition}"
  docker_image_tag    = "${var.nexus_definition["docker_image_tag"]}"

  ecs_details = {
    cluster_id                = "${module.pipeline_ecs.cluster_id}"
    iam_role                  = "${module.pipeline_ecs.iam_role}"
    cw_app_pipeline_log_group = "${var.name}/${var.environment}/nexus"
    jenkins_ip                = "http://10.0.1.113:8080/jenkins"           #TODO Hardcoded
    consul_private_ip         = "${module.vpc_pipeline.consul_private_ip}"
  }

  region = "${var.region}"

  target_group_id = "${module.pipeline_ecs.target_group_id[2]}" #Nexus
}

module "jenkins" {
  source              = "modules/jenkins_terraform_module"
  environment         = "${var.environment}"
  name                = "${var.name}"
  pipeline_definition = "${var.jenkins_pipeline_definition}"
  docker_image_tag    = "${var.jenkins_pipeline_definition["docker_image_tag"]}"

  ecs_details = {
    cluster_id                = "${module.pipeline_ecs.cluster_id}"
    iam_role                  = "${module.pipeline_ecs.iam_role}"
    cw_app_pipeline_log_group = "${var.name}/${var.environment}/jenkins"
    ecs_cluster               = "${module.pipeline_ecs.cluster_name}"
    jenkins_ip                = "http://10.0.1.113:8080/jenkins"                 #TODO Hardcoded
    aws_account_id            = "${data.aws_caller_identity.current.account_id}"
  }

  region = "${var.region}"

  target_group_id = "${module.pipeline_ecs.target_group_id[0]}" #Jenkins
}

module "ecr_repos" {
  source      = "modules/ecr_terraform_module"
  environment = "${var.environment}"
  registries  = ["pipeline/jenkins", "pipeline/consul"] #TODO Vars
}

resource "aws_key_pair" "deployer" {
  public_key = ""
}
