output "vpn_ip" {
  value = "${module.vpn_instance.vpn_ip}"
}

output "alb_endpoint" {
  value = "${module.pipeline_ecs.alb_endpoint}"
}

output "debug_box_private_ip" {
  value = "${aws_instance.debug_box.private_ip}"
}

output "consul_private_ip" {
  value = "${module.vpc_pipeline.consul_private_ip}"
}

output "vpc_id" {
  value = "${module.vpc_pipeline.id}"
}

output "private_subnet_ids" {
  value = ["${module.vpc_pipeline.private_subnet_ids}"]
}
