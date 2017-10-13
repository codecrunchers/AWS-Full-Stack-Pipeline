resource "aws_instance" "vpn" {
  vpc_security_group_ids = ["${aws_security_group.vpn.id}"]
  subnet_id              = "${var.subnets[0]}"

  instance_type = "t2.micro"
  ami           = "${var.vpn_instance_details["ami"]}"
  instance_type = "${var.vpn_instance_details["size"]}"
  key_name      = "${var.vpn_instance_details["key_name"]}"

  lifecycle {
    #  prevent_destroy = true
  }

  tags {
    "Name"       = "${var.stack_details["env"]}-${var.stack_details["stack_name"]}-vpn"
    "stack_name" = "${var.stack_details["stack_name"]}"
    "stack_id"   = "${var.stack_details["stack_id"]}"
    "ServerRole" = "VPN"
  }
}

#TODO: Register DNS
#resource "aws_route53_record" "dns" {
#  zone_id = "${data.aws_route53_zone.primary.zone_id}"
#  name    = "${var.environment}-vpn"
#  type    = "A"
#  ttl     = "300"
#  records = ["${aws_instance.vpn.public_ip}"]
#}


#data "aws_route53_zone" "primary" {
#  name   = "${var.dns_zone}"
#  vpc_id = "${var.vpc_id}"
#}

