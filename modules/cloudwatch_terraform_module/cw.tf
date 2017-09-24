resource "aws_cloudwatch_log_group" "log_group" {
  name              = "${var.name}/${var.environment}/${var.app["name"]}"
  retention_in_days = 14
}
