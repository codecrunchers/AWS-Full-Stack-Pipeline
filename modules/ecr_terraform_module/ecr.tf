resource "aws_ecr_repository" "ecr" {
  count = "${length(var.registries)}"
  name  = "${lower(var.stack_details["env"])}.${lower(var.registries[count.index])}" #(?:[a-z0-9]+(?:[._-][a-z0-9]+)*\/)*[a-z0-9]+(?:[._-][a-z0-9]+)*
}
