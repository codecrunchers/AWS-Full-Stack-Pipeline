resource "aws_instance" "debug_box" {
  ami                         = "ami-ebd02392"
  instance_type               = "t2.micro"
  subnet_id                   = "${module.vpc_pipeline.private_subnet_ids[0]}"
  associate_public_ip_address = false
  key_name                    = "pipeline"
  security_groups             = ["${aws_security_group.debug_box_gs.id}"]

  tags {
    Name = "Debug Box in Private Network"
  }
}

resource "aws_security_group" "debug_box_gs" {
  description = "Controls access to the application ALB"
  vpc_id      = "${module.vpc_pipeline.id}"
  name        = "${var.environment}-${var.name}-ecs-sg"

  ingress {
    protocol  = "tcp"
    from_port = "22"
    to_port   = "22"

    cidr_blocks = ["${module.vpc_pipeline.cidr_block}"]
  }

  egress {
    protocol  = "tcp"
    from_port = "22"
    to_port   = "22"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags {
    Name = "Allow Specified CIDR Blocks to Access Alb"
  }
}
