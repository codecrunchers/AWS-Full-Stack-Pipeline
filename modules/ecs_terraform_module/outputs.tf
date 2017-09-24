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

output "alb_endpoint" {
  value = "${aws_alb.alb.dns_name}"
}

output "alb_endpoint_zone_id" {
  value = "${aws_alb.alb.zone_id}"
}

output "alb_endpoint_ip" {
  value = "${aws_alb.alb.dns_name.public_ip}"
}
