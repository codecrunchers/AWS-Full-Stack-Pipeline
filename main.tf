#Pipeline VPC
module "vpc_pipeline" {
  source        = "git@github.com:Plnt9/vpc_terraform_module.git"
  vpc_name      = "p9-pipeline-${var.stack_details["env"]}"
  stack_details = "${var.stack_details}"
  vpc_details   = "${var.vpc_details_pipeline}"
  subnet_cidrs  = "${var.subnet_cidrs_pipeline}"
}

module "vpn_instance" {
  source                = "modules/openvpn_terraform_module"
  vpc_id                = "${module.vpc_pipeline.vpc_id}"
  subnets               = "${module.vpc_pipeline.network_info["red"]}"
  vpn_instance_details  = "${var.vpn_instance_details}"
  whitelist_cidr_blocks = "${var.external_access_cidr_block}"
  dns_zone              = "${var.dns_zone}"
  stack_details         = "${var.stack_details}"
}

module "pipeline_storage" {
  source             = "modules/filesystem_terraform_module"
  environment        = "${var.stack_details["env"]}"
  name               = "${var.stack_details["stack_name"]}"
  private_subnet_ids = "${module.vpc_pipeline.network_info["green"]}"
  vpc_id             = "${module.vpc_pipeline.vpc_id}"
}

module "cloudwatch_pipeline" {
  source      = "modules/cloudwatch_terraform_module"
  environment = "${var.stack_details["env"]}"
  name        = "${var.stack_details["stack_name"]}"

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

module "pipeline_ecs" {
  source             = "modules/ecs_terraform_module"
  vpc_id             = "${module.vpc_pipeline.vpc_id}"
  cluster_name       = "${var.stack_details["stack_name"]}"
  public_subnet_ids  = "${module.vpc_pipeline.network_info["red"]}"
  private_subnets    = "${module.vpc_pipeline.network_info["amber"]}"
  private_subnet_ids = "${module.vpc_pipeline.network_info["amber"]}"
  efs_mount_dns      = "${module.pipeline_storage.efs_mount_dns}"
  dns_zone           = "${var.dns_zone}"
  ssh_key            = "${var.key_name}"
  stack_details      = "${var.stack_details}"

  whitelist_cidr_blocks = [
    "${var.alb_whitelist_cidr_blocks}",
    "${formatlist("%s/32", module.vpc_pipeline.network_info["nat_ips"])}",
  ]

  low_port              = 8080                                                                                  #TODO mmmm
  high_port             = 9000
  vpc_id                = "${module.vpc_pipeline.vpc_id}"
  ecs_params            = "${var.ecs_params}"
  cloudwatch_log_handle = "${module.cloudwatch_pipeline.cw_handle[0]}"
  alb_target_groups     = "${list(var.jenkins_pipeline_definition,var.consul_definition,var.nexus_definition)}"
  consul_private_ip     = "ConsulIP:TODO"                                                                       #"${module.vpc_pipeline.consul_private_ip}"
}
