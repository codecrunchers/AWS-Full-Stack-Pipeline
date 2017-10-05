resource "aws_ecs_service" "consul_ecs_service" {
  name            = "${lookup(var.consul_definition,"name")}"
  cluster         = "${lookup(var.ecs_details,"cluster_id")}"
  task_definition = "${aws_ecs_task_definition.consul.arn}"
  desired_count   = 1                                         #TODO: "${lookup(var.consul_definition,"instance_count")}"
}
