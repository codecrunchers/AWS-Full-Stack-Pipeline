#TODO: This has all been imported
resource "aws_security_group" "pipeline-storage" {
  description = "Production EFS Persistence"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name = "EFS for Pipeline"
  }
}

resource "aws_security_group_rule" "pipeline-storage" {
  security_group_id = "${aws_security_group.pipeline-storage.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 0
  to_port           = 65535
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "pipeline-storage-1" {
  security_group_id = "${aws_security_group.pipeline-storage.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 0
  to_port           = 65535
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "pipeline-storage-2" {
  security_group_id = "${aws_security_group.pipeline-storage.id}"
  type              = "egress"
  protocol          = -1
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "alb_sg" {
  description = "Controls access to the application ALB"
  vpc_id      = "${var.vpc_id}"
  name        = "${var.stack_details["env"]}-${var.ecs_params["ecs_name"]}-ecs-sg"

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
    Name = "Allow Specified CIDR Blocks to Access Alb"
  }
}

resource "aws_security_group" "ecs_instance_sg" {
  description = "Controls direct access to application instances"
  vpc_id      = "${var.vpc_id}"
  name        = "${var.stack_details["env"]}-${var.ecs_params["ecs_name"]}-ecs-instsg"

  ingress {
    protocol  = "tcp"
    from_port = "${var.low_port}"
    to_port   = "${var.high_port}"

    security_groups = [
      "${aws_security_group.alb_sg.id}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "ECS/EC2 Allow Range 8000->9999"
  }
}
