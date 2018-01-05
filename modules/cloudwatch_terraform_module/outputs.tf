output "cw_handle" {
  value = ["${aws_cloudwatch_log_group.log_group.*.arn}"]
}
