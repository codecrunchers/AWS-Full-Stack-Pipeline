output "alb_endpoint" {
  value = "${module.pipeline_ecs.alb_endpoint}"
}

output "debug_box_private_ip" {
  value = "${aws_instance.debug_box.private_ip}"
}

output "consul_private_ip" {
  value = "${module.vpc_pipeline.consul_private_ip}"
}
