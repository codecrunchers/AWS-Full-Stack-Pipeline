resource "aws_ecs_cluster" "ecs" {
  name = "${var.environment}-${var.name}"
}
