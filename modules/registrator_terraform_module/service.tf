resource "aws_ecs_service" "registrator_service" {
  name            = "${lookup(var.registrator_definition,"name")}"
  cluster         = "${lookup(var.ecs_details,"cluster_id")}"
  task_definition = "${aws_ecs_task_definition.registrator.arn}"
  desired_count   = "${lookup(var.ecs_details,"desired_count")}"
}
