##
# Consul cluster setup
##

resource "aws_security_group" "consul" {
  name        = "consul"
  description = "Consul internal traffic + maintenance."
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    self        = true
    cidr_blocks = ["${var.cidr_block}"]
  }

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    self        = true
    cidr_blocks = ["${var.cidr_block}"]
  }

  ingress {
    from_port   = 8300
    to_port     = 8302
    protocol    = "tcp"
    self        = true
    cidr_blocks = ["${var.cidr_block}"]
  }

  ingress {
    from_port   = 8301
    to_port     = 8302
    protocol    = "udp"
    self        = true
    cidr_blocks = ["${var.cidr_block}"]
  }

  ingress {
    from_port   = 8400
    to_port     = 8400
    protocol    = "tcp"
    self        = true
    cidr_blocks = ["${var.cidr_block}"]
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    self        = true
    cidr_blocks = ["${var.cidr_block}"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_route53_zone" "primary" {
  name   = "${var.DnsZoneName}"
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_route53_record" "consul" {
  zone_id = "${data.aws_route53_zone.primary.zone_id}"
  name    = "consul.${var.DnsZoneName}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.consulinstance.private_ip}"]
}

data "aws_region" "region" {
  current = true
}

resource "aws_instance" "consulinstance" {
  ami           = "${lookup(var.ecs_amis, data.aws_region.region.name)}"
  instance_type = "t2.small"
  key_name      = "${var.key_name}"

  iam_instance_profile = "${var.iam_ecs}"

  vpc_security_group_ids = [
    "${aws_security_group.consul.id}",
  ]

  subnet_id = "${element(aws_subnet.private.*.id,0)}"

  depends_on = ["aws_subnet.private"]

  tags = {
    Name        = "consul${count.index}"
    subnet      = "private"
    role        = "dns"
    environment = "${var.environment}"
  }

  user_data = "${data.template_file.user_data.rendered}"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/templates/consul-bash-script.sh")}"

  vars {
    #  vpc_dns_host = "${aws_instance.consulinstance.public_dns}" //set by user-init
    vpc_region = "${data.aws_region.region.name}"
  }
}
