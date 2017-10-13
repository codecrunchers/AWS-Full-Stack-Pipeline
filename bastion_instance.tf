resource "aws_instance" "debug_box" {
  ami           = "ami-ebd02392"                                            #TODO Get better Tooled box
  instance_type = "t2.micro"                                                #TODO Var
  subnet_id     = "${element(module.vpc_pipeline.network_info["amber"],0)}"

  associate_public_ip_address = false
  key_name                    = "${var.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.debug_box_gs.id}"]

  tags {
    Name         = "Debug Box in Private Network (${var.stack_details["env"]}-${var.stack_details["stack_name"]})"
    "stack_name" = "${var.stack_details["stack_name"]}"
    "stack_id"   = "${var.stack_details["stack_id"]}"
    ServerRole   = "Bastion"
  }
}

resource "aws_security_group" "debug_box_gs" {
  description = "Controls access to the Debug Box within VPN"
  vpc_id      = "${module.vpc_pipeline.vpc_id}"
  name        = "${var.stack_details["env"]}-${var.stack_details["stack_name"]}-debugbox-sg"

  ingress {
    protocol  = "tcp"
    from_port = "22"
    to_port   = "22"

    cidr_blocks = ["10.171.64.0/20"]
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
    Name = "Security for Debug Box, allow access from cidr_block"
  }
}
