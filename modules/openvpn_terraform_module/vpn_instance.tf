resource "aws_instance" "vpn" {
  vpc_security_group_ids = ["${aws_security_group.vpn.id}"]
  subnet_id              = "${var.subnets[0]}"

  ami           = "${var.vpn_instance_details["ami"]}"
  instance_type = "${var.vpn_instance_details["size"]}"
  key_name      = "${var.vpn_instance_details["key_name"]}"

  lifecycle {
    #  prevent_destroy = true
  }

  tags {
    Name       = "${var.stack_details["env"]}-vpn"
    stack_name = "${var.stack_details["stack_name"]}"
    stack_id   = "${var.stack_details["stack_id"]}"
    ServerRole = "VPN"
  }
}

resource "aws_eip" "vpn" {
  instance = "${aws_instance.vpn.id}"
  vpc      = true
}
