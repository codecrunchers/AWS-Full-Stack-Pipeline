resource "aws_ecs_service" "jenkins_slave_ecs_service" {
  name            = "${lookup(var.slave_pipeline_definition,"name")}"
  cluster         = "${lookup(var.ecs_details,"cluster_id")}"
  task_definition = "${aws_ecs_task_definition.slave.arn}"
  desired_count   = "${lookup(var.slave_pipeline_definition,"instance_count")}"

  #  iam_role        = "${lookup(var.ecs_details,"iam_role")}"
}
