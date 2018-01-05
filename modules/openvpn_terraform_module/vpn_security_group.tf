resource "aws_security_group" "vpn" {
  name   = "${lower(var.stack_details["env"])}-VPN SG"
  vpc_id = "${var.vpc_id}"
}

resource "aws_security_group_rule" "vpn_egress_all" {
  security_group_id = "${aws_security_group.vpn.id}"

  type        = "egress"
  from_port   = 0
  to_port     = 65535
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "vpn_ingress_22" {
  security_group_id = "${aws_security_group.vpn.id}"

  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  cidr_blocks = "${var.whitelist_cidr_blocks}"
}

resource "aws_security_group_rule" "vpn_ingress_443" {
  security_group_id = "${aws_security_group.vpn.id}"

  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  cidr_blocks = "${var.whitelist_cidr_blocks}"
}

resource "aws_security_group_rule" "vpn_ingress_943" {
  security_group_id = "${aws_security_group.vpn.id}"

  type      = "ingress"
  from_port = 943
  to_port   = 943
  protocol  = "tcp"

  cidr_blocks = "${var.whitelist_cidr_blocks}"
}

resource "aws_security_group_rule" "vpn_ingress_1194" {
  security_group_id = "${aws_security_group.vpn.id}"

  type      = "ingress"
  from_port = 1194
  to_port   = 1194
  protocol  = "udp"

  cidr_blocks = "${var.whitelist_cidr_blocks}"
}
