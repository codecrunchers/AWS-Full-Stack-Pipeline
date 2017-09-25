resource "aws_ecr_repository" "ecr" {
  count = "${length(var.registries)}"
  name  = "${var.environment}-${var.registries[count.index]}"
}
