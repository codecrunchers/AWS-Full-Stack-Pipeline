resource "aws_ecr_repository" "ecr" {
  count = "${length(var.registries)}"
  name  = "${var.stack_details["env"]}-${var.registries[count.index]}"
}
