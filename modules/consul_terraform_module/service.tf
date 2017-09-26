resource "aws_ecs_service" "consul_ecs_service" {
  name            = "${lookup(var.consul_definition,"name")}"
  cluster         = "${lookup(var.ecs_details,"cluster_id")}"
  task_definition = "${aws_ecs_task_definition.consul.arn}"
  desired_count   = "${lookup(var.consul_definition,"instance_count")}"
  iam_role        = "${lookup(var.ecs_details,"iam_role")}"

  load_balancer {
    target_group_arn = "${var.target_group_id}"
    container_name   = "${lookup(var.consul_definition,"name")}"
    container_port   = "${lookup(var.consul_definition,"container_port_to_expose")}"
  }
}
