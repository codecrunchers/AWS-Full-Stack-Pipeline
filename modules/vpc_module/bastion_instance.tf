resource "aws_instance" "bastion" {
  ami           = "ami-ebd02392"                          #TODO Get better Tooled box
  instance_type = "t2.micro"                              #TODO Var
  subnet_id     = "${element(aws_subnet.private.*.id,0)}"

  associate_public_ip_address = false
  key_name                    = "${var.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.bastion.id}"]

  tags {
    Name        = "Bastion"
    stack_id    = "${var.stack_details["stack_id"]}"
    stack_name  = "${var.stack_details["stack_name"]}"
    Environment = "${var.stack_details["env"]}"
    ServerRole  = "Bastion"
  }
}

resource "aws_security_group" "bastion" {
  name        = "bastion-sg"
  description = "Controls access to the Debug Box within VPN"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    protocol  = "tcp"
    from_port = "22"
    to_port   = "22"

    cidr_blocks = ["${var.cidr_block}", "37.228.251.43/32"] #TODO: HardCoded
  }

  egress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags {
    Name        = "Security for Debug Box"
    stack_id    = "${var.stack_details["stack_id"]}"
    stack_name  = "${var.stack_details["stack_name"]}"
    Environment = "${var.stack_details["env"]}"
  }
}
