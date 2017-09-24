variable alb_target_groups {
  type = "list"
}

private_subnets private_subnet_ids public_subnets public_subnet_ids dns_zone name environment variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "eu-west-1"
}

variable "ecs_amis" {
  type = "map"

  default = {
    eu-west-1 = "ami-809f84e6"
    eu-west-2 = "ami-ff15039b"
  }
}

variable ecs_params {
  type = "map"
}

variable "whitelist_cidr_blocks" {
  type = "list"
}

variable "low_port" {}

variable "high_port" {}

variable "vpc_id" {}

variable "cloudwatch_log_handle" {}

output "cluster_name" {
  value = "${aws_ecs_cluster.ecs.name}"
}

output "cluster_id" {
  value = "${aws_ecs_cluster.ecs.id}"
}

output "iam_role" {
  value = "${aws_iam_role.ecs_service_role.id}"
}

output "target_group_id" {
  value = "${aws_alb_target_group.alb_target_groups.*.id}" #TODO will become list
}

output "efs_mount_dns" {
  value = "${aws_efs_mount_target.efs_mt.0.dns_name}"
}

output "alb_endpoint" {
  value = "${aws_alb.alb.dns_name}"
}

output "alb_endpoint_zone_id" {
  value = "${aws_alb.alb.zone_id}"
}

output "alb_endpoint_ip" {
  value = "${aws_alb.alb.dns_name.public_ip}"
}
