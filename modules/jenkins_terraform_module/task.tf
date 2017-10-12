resource "aws_ecs_task_definition" "pipeline" {
  family                = "${format("%s_%s_family", var.environment,lookup(var.pipeline_definition,"name"))}"
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
    consul_ip        = "${var.consul_private_ip}"
    image_url        = "${var.docker_image_tag}"
    container_name   = "${lookup(var.pipeline_definition, "name")}"
    log_group_name   = "${lookup(var.ecs_details, "cw_app_pipeline_log_group")}"
    log_group_region = "${var.region}"
    container_port   = "${lookup(var.pipeline_definition, "container_port_to_expose")}"
    host_port        = "${lookup(var.pipeline_definition, "host_port_to_expose")}"
    memory           = "${lookup(var.pipeline_definition, "instance_memory_allocation")}"
    ecs_cluster      = "${lookup(var.ecs_details, "ecs_cluster")}"
    aws_region       = "${var.region}"
    aws_account_id   = "${lookup(var.ecs_details, "aws_account_id")}"
  }
}
