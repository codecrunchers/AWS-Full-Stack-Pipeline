output "jenkins_endpoint" {
  value = "http://${module.pipeline_ecs.alb_endpoint}/jenkins/"
}

output "nexus_endpoint" {
  value = "http://${module.pipeline_ecs.alb_endpoint}/nexus/"
}

output "bastion_private_ip" {
  value = "${aws_instance.debug_box.private_ip}"
}

output "consul_private_ip" {
  value = "${module.vpc_pipeline.consul_private_ip}"
}

output "vpn_ip" {
  value = "${module.vpn_instance.vpn_ip}"
}

output "vpc_id" {
  value = "${module.vpc_pipeline.id}"
}

output "private_subnet_ids" {
  value = ["${module.vpc_pipeline.private_subnet_ids}"]
}
