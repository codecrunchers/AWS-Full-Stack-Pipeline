resource "aws_ecs_cluster" "ecs" {
  name = "${var.stack_details["env"]}-${var.ecs_params["ecs_name"]}"
}
