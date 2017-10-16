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

module "nexus" {
  stack_details       = "${var.stack_details}"
  source              = "modules/nexus_terraform_module"
  pipeline_definition = "${var.nexus_definition}"
  docker_image_tag    = "${var.nexus_definition["docker_image_tag"]}"
  consul_private_ip   = "ConsulIP:TODO"                               #"${module.vpc_pipeline.consul_private_ip}"d

  ecs_details = {
    cluster_id                = "${module.pipeline_ecs.cluster_id}"                                    #TODO: Refactor these maps, messy
    iam_role                  = "${module.pipeline_ecs.iam_role}"
    cw_app_pipeline_log_group = "${var.stack_details["stack_name"]}/${var.stack_details["env"]}/nexus"
    jenkins_ip                = "http://jenkinsci-8080.service.consul:8080/jenkins"
  }

  region = "${var.region}"

  target_group_id = "${module.pipeline_ecs.target_group_id[2]}" #Nexus
}

module "jenkins" {
  stack_details       = "${var.stack_details}"
  source              = "modules/jenkins_terraform_module"
  pipeline_definition = "${var.jenkins_pipeline_definition}"
  docker_image_tag    = "${var.jenkins_pipeline_definition["docker_image_tag"]}"
  consul_private_ip   = "Consul.IP"                                              #${module.vpc_pipeline.consul_private_ip}"

  ecs_details = {
    cluster_id                = "${module.pipeline_ecs.cluster_id}"
    iam_role                  = "${module.pipeline_ecs.iam_role}"
    cw_app_pipeline_log_group = "${var.stack_details["stack_name"]}/${var.stack_details["env"]}/jenkins"
    ecs_cluster               = "${module.pipeline_ecs.cluster_name}"
    aws_account_id            = "${data.aws_caller_identity.current.account_id}"
  }

  region = "${var.region}"

  target_group_id = "${module.pipeline_ecs.target_group_id[0]}" #Jenkins
}

module "sonar_db" {
  source                = "git@github.com:Plnt9/rds_terraform_module.git"
  stack_details         = "${var.stack_details}"
  instance_details      = "${var.sonar_db_instance}"
  rds_subnets           = "${module.vpc_pipeline.network_info["green"]}"
  vpc_id                = "${module.vpc_pipeline.vpc_id}"
  whitelist_cidr_blocks = ["10.171.64.0/20"]                              #allow database to talk to peered pipeline vpc
}

module "sonar" {
  source = "modules/sonar_terraform_module"

  pipeline_definition = "${var.sonar_pipeline_definition}"
  docker_image_tag    = "${var.sonar_pipeline_definition["docker_image_tag"]}"
  consul_private_ip   = "Consul.IP"                                            #${module.vpc_pipeline.consul_private_ip}"
  region              = "${var.region}"

  ecs_details = {
    cluster_id                = "${module.pipeline_ecs.cluster_id}"                                    #TODO: Refactor these maps, messy
    iam_role                  = "${module.pipeline_ecs.iam_role}"
    cw_app_pipeline_log_group = "${var.stack_details["stack_name"]}/${var.stack_details["env"]}/nexus"
    jenkins_ip                = "http://jenkinsci-8080.service.consul:8080/jenkins"
  }

  target_group_id = "${module.pipeline_ecs.target_group_id[1]}" #TODO: hcoded Full list needed
  stack_details   = "${var.stack_details}"

  rds_details  = "${var.sonar_db_instance}"
  rds_endpoint = "${module.sonar_db.db_host}"
}

module "ecr_repos" {
  source      = "modules/ecr_terraform_module"
  environment = "${var.stack_details["env"]}"
  registries  = ["pipeline/jenkins", "pipeline/consul", "pipeline/sonar", "pipeline/nexus"] #TODO Vars
}
