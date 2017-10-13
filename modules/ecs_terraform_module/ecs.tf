resource "aws_ecs_cluster" "ecs" {
  name = "${var.stack_details["env"]}-${var.stack_details["stack_name"]}"
}
