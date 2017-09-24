output "efs_mount_dns" {
  value = "${aws_efs_mount_target.efs_mt.0.dns_name}"
}
