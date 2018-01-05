#These are Private Hosted Zones, the same domain can be attached to multiple private and a single public zone.
#This has the effect of resource.my-domain.com potentially pointing to different instances in differing VPCS
module "pipeline_dns" {
  source        = "modules/route53_terraform_module"
  dns_zone_name = "${var.dns_zone}"
  stack_details = "${var.stack_details}"
  vpc_id        = "${module.pipeline_vpc.id}"
  force_destroy = true                               #recursive delete

  zone_records = [
    {
      record = "${module.pipeline_vpn.vpn_ip}"
      ttl    = "300"
      type   = "A"
      name   = "vpn"
    },
    {
      record = "${module.pipeline_ecs.alb_endpoint}"
      ttl    = "300"
      type   = "CNAME"
      name   = "pipeline"
    },
  ]
}

module "pipeline_vpc" {
  source                         = "modules/vpc_module"
  key_name                       = "${var.key_name}"
  cidr_block                     = "${var.pipeline_cidr_block}"
  vpc_external_access_cidr_block = "${var.pipeline_external_access_cidr_block}"
  vpc_private_subnet_cidr_blocks = "${var.pipeline_private_subnet_cidr_blocks}"
  vpc_public_subnet_cidr_blocks  = "${var.pipeline_public_subnet_cidr_blocks}"
  vpc_availability_zones         = "${var.pipeline_availability_zones}"
  iam_ecs                        = "${module.pipeline_ecs.iam_ecs}"
  dns_zone_name                  = "${var.dns_zone}"
  stack_details                  = "${var.stack_details}"
}

module "pipeline_vpn" {
  source                = "modules/openvpn_terraform_module"
  vpc_id                = "${module.pipeline_vpc.id}"
  subnets               = "${module.pipeline_vpc.public_subnet_ids}"
  whitelist_cidr_blocks = "${var.pipeline_external_access_cidr_block}"
  vpn_instance_details  = "${var.vpn_instance_details}"
  dns_zone              = "${var.dns_zone}"
  stack_details         = "${var.stack_details}"
}

module "pipeline_ecs" {
  source             = "modules/ecs_terraform_module"
  vpc_id             = "${module.vpc.id}"
  public_subnet_ids  = "${module.pipeline_vpc.public_subnet_ids}"
  private_subnet_ids = "${module.pipeline_vpc.private_subnet_ids}"
  efs_mount_dns      = "${module.pipeline_storage.efs_mount_dns}"
  dns_zone           = "${var.dns_zone}"
  ssh_key            = "${var.key_name}"
  stack_details      = "${var.stack_details}"
  vpc_cidr           = "${var.pipeline_cidr_block}"

  whitelist_cidr_blocks = [
    "${formatlist("%s/32", module.pipeline_vpc.nat_gateway_ips)}",
    "37.228.251.43/32",                                            #ME
  ]

  low_port              = 8080                                                            #TODO mmmm
  high_port             = 9000
  ecs_params            = "${var.ecs_params}"
  cloudwatch_log_handle = "${module.pipeline_cloudwatch.cw_handle[0]}"
  alb_target_groups     = "${list(var.jenkins_pipeline_definition,var.nexus_definition)}"
}
