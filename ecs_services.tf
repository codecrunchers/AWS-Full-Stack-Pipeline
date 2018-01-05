module "pipeline_cloudwatch" {
  source        = "modules/cloudwatch_terraform_module"
  stack_details = "${var.stack_details}"

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
    {
      name              = "buildslave"
      retention_in_days = 14
    },
  ]
}

module "pipeline_storage" {
  source             = "modules/filesystem_terraform_module"
  stack_details      = "${var.stack_details}"
  private_subnet_ids = "${module.pipeline_vpc.private_subnet_ids}"
  vpc_id             = "${module.pipeline_vpc.id}"
}

module "nexus" {
  source        = "modules/nexus_terraform_module"
  stack_details = "${var.stack_details}"

  pipeline_definition = "${var.nexus_definition}"
  docker_image_tag    = "${var.nexus_definition["docker_image_tag"]}"

  ecs_details = {
    cluster_id                = "${module.pipeline_ecs.cluster_id}"                                    #TODO: Refactor these maps, messy
    iam_role                  = "${module.pipeline_ecs.iam_role}"
    cw_app_pipeline_log_group = "${var.stack_details["stack_name"]}/${var.stack_details["env"]}/nexus"
  }

  jenkins_host    = "http://${module.pipeline_ecs.alb_endpoint}/jenkins/"
  target_group_id = "${module.pipeline_ecs.target_group_id[1]}"           #Nexus
}

module "jenkins" {
  source              = "modules/jenkins_terraform_module"
  pipeline_definition = "${var.jenkins_pipeline_definition}"

  stack_details    = "${var.stack_details}"
  docker_image_tag = "${var.jenkins_pipeline_definition["docker_image_tag"]}"
  jenkins_host     = "http://${module.pipeline_ecs.alb_endpoint}/jenkins/"

  ecs_details = {
    cluster_id                = "${module.pipeline_ecs.cluster_id}"
    iam_role                  = "${module.pipeline_ecs.iam_role}"
    cw_app_pipeline_log_group = "${var.stack_details["stack_name"]}/${var.stack_details["env"]}/jenkins"
    ecs_cluster               = "${module.pipeline_ecs.cluster_name}"
    aws_account_id            = "${data.aws_caller_identity.current.account_id}"
    vpc_cidr_block            = "${module.pipeline_vpc.cidr_block}"
  }

  target_group_id = "${module.pipeline_ecs.target_group_id[0]}" #Jenkins
}

module "pipeline_ecr" {
  source        = "modules/ecr_terraform_module"
  registries    = ["pipeline.jenkins", "pipeline.consul", "pipeline.nexus", "pipeline.sonar"]
  stack_details = "${var.stack_details}"
}
