#For the load balancer
resource "aws_security_group" "alb_sg" {
  description = "Controls access to the application ALB"
  vpc_id      = "${var.vpc_id}"
  name        = "${var.stack_details["env"]}-${var.stack_details["stack_name"]}-ecs-sg"

  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol  = "tcp"
    from_port = 50000
    to_port   = 50000

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol  = "tcp"
    from_port = "0"
    to_port   = "65535"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags {
    Name        = "Allow Specified CIDR Blocks to Access Alb"
    stack_id    = "${var.stack_details["stack_id"]}"
    stack_name  = "${var.stack_details["stack_name"]}"
    Environment = "${var.stack_details["env"]}"
  }
}

#For the the EC2 Docker Host
resource "aws_security_group" "ecs_instance_sg" {
  description = "Controls direct access to pipeline host instances"
  vpc_id      = "${var.vpc_id}"
  name        = "${var.stack_details["env"]}-${var.stack_details["stack_name"]}-ecs-instsg"

  ingress {
    protocol    = "tcp"
    from_port   = "${var.low_port}"
    to_port     = "${var.high_port}"
    cidr_blocks = ["${var.vpc_cidr}"]

    security_groups = [
      "${aws_security_group.alb_sg.id}",
    ]
  }

  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22

    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    protocol  = "tcp"
    from_port = 50000
    to_port   = 50000

    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "ECS/EC2 Allow Range ${var.low_port} to ${var.high_port}"
    stack_id    = "${var.stack_details["stack_id"]}"
    stack_name  = "${var.stack_details["stack_name"]}"
    Environment = "${var.stack_details["env"]}"
  }
}
