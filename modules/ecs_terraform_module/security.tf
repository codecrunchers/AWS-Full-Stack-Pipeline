resource "aws_security_group" "alb_sg" {
  description = "Controls access to the application ALB"
  vpc_id      = "${var.vpc_id}"
  name        = "${var.stack_details["env"]}-${var.stack_details["stack_name"]}-ecs-sg"

  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80

    cidr_blocks = ["${var.whitelist_cidr_blocks}"]
  }

  egress {
    protocol  = "tcp"
    from_port = "${var.low_port}"
    to_port   = "${var.high_port}"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags {
    Name        = "Allow Specified CIDR Blocks to Access Alb"
    Environment = "${var.stack_details["env"]}"
  }
}

resource "aws_security_group" "ecs_instance_sg" {
  description = "Controls direct access to application instances"
  vpc_id      = "${var.vpc_id}"
  name        = "${var.stack_details["env"]}-${var.stack_details["stack_name"]}-ecs-instsg"

  ingress {
    protocol  = "tcp"
    from_port = "${var.low_port}"
    to_port   = "${var.high_port}"

    security_groups = [
      "${aws_security_group.alb_sg.id}",
    ]
  }

  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22

    security_groups = [
      "${aws_security_group.alb_sg.id}",
    ]

    cidr_blocks = ["10.171.64.0/20"] #TODO: Bug, Get CIDR Block Based on VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name       = "ECS/EC2 Allow Range ${var.low_port} to ${var.high_port}"
    stack_name = ""                                                        #TODO
    stack_id   = ""                                                        #TODO
  }
}
