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
}

resource "aws_instance" "consulinstance" {
  ami           = "ami-785db401"
  instance_type = "t2.micro"
  key_name      = "${var.key_name}"

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
  template = "${file("${path.module}/templates/consul-user-data-bash.instance")}"
}
