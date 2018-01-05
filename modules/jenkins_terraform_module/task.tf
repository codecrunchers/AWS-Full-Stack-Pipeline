resource "aws_ecs_task_definition" "pipeline" {
  family                = "${format("%s_%s_family", var.stack_details["env"],lookup(var.pipeline_definition,"name"))}"
  container_definitions = "${data.template_file.jenkins_task_definition_file.rendered}"

  volume {
    name      = "jenkins_home"
    host_path = "/efs/jenkins_home/"
  }

  volume {
    name      = "p9_backups"
    host_path = "/efs/backup/"
  }
}

data "template_file" "jenkins_task_definition_file" {
  template = "${file("${path.module}/templates/task-definition.json")}"

  vars {
    jenkins_host             = "${var.jenkins_host}"
    image_url                = "${var.docker_image_tag}"
    container_name           = "${lookup(var.pipeline_definition, "name")}"
    log_group_name           = "${lookup(var.ecs_details, "cw_app_pipeline_log_group")}"
    log_group_region         = "${data.aws_region.current.name}"
    container_port           = "${lookup(var.pipeline_definition, "container_port_to_expose")}"
    host_port                = "${lookup(var.pipeline_definition, "host_port_to_expose")}"
    memory                   = "${lookup(var.pipeline_definition, "instance_memory_allocation")}"
    ecs_cluster              = "${lookup(var.ecs_details, "ecs_cluster")}"
    aws_region               = "${data.aws_region.current.name}"
    aws_account_id           = "${lookup(var.ecs_details, "aws_account_id")}"
    vpc_dns_server           = "${cidrhost(lookup(var.ecs_details,"vpc_cidr_block"),2)}"
    GITHUB_APP_CLIENT_ID     = "${lookup(var.pipeline_definition, "github_app_client_id")}"
    GITHUB_APP_CLIENT_SECRET = "${lookup(var.pipeline_definition, "github_app_client_secret")}"
  }
}

data "aws_region" "current" {
  current = true
}
