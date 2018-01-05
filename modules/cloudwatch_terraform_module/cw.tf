resource "aws_cloudwatch_log_group" "log_group" {
  count             = "${length(var.groups)}"
  name              = "${var.stack_details["stack_name"]}/${var.stack_details["env"]}/${lookup(var.groups[count.index],"name")}"
  retention_in_days = "${lookup(var.groups[count.index],"retention_in_days")}"
}
