resource "aws_ecs_cluster" "ecs" {
  name = "${var.cluster_name}"
}
