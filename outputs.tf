output "pipeline_vpc_cidr_block" {
  value = "${module.pipeline_vpc.cidr_block}"
}

output "jenkins_endpoint" {
  value = "http://${module.pipeline_ecs.alb_endpoint}/jenkins/"
}

output "nexus_endpoint" {
  value = "http://${module.pipeline_ecs.alb_endpoint}/nexus/"
}

output "pipeline_bastion_private_ip" {
  value = "${module.pipeline_vpc.bastion_private_ip}"
}

output "pipeline_vpn_ip" {
  value = "${module.pipeline_vpn.vpn_ip} (Elastic)"
}

output "pipeline_vpc_id" {
  value = "${module.pipeline_vpc.id}"
}

output "pipeline_private_subnet_ids" {
  value = ["${module.pipeline_vpc.private_subnet_ids}"]
}
