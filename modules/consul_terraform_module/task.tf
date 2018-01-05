resource "aws_ecs_task_definition" "consul" {
  family                = "${format("%s_%s_family", var.stack_details["env"], lookup(var.consul_definition,"name"))}"
  container_definitions = "${data.template_file.consul_definition_file.rendered}"
}

data "template_file" "consul_definition_file" {
  template = "${file("${path.module}/templates/client-task-definition.json")}"

  vars {
    image_url        = "${var.docker_image_tag}"
    container_name   = "${lookup(var.consul_definition, "name")}"
    log_group_name   = "${lookup(var.ecs_details, "cw_app_pipeline_log_group")}"
    log_group_region = "${var.region}"
    container_port   = "${lookup(var.consul_definition, "container_port_to_expose")}"
    host_port        = "${lookup(var.consul_definition, "host_port_to_expose")}"
    memory           = "${lookup(var.consul_definition, "instance_memory_allocation")}"
    consul_ip        = "${var.consul_private_ip}"
    region           = "${var.region}"
  }
}
