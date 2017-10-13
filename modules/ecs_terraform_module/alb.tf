resource "aws_alb" "alb" {
  name            = "${var.stack_details["env"]}-${var.stack_details["stack_name"]}-alb"
  subnets         = ["${var.public_subnet_ids}"]
  security_groups = ["${aws_security_group.alb_sg.id}"]
}

resource "aws_alb_target_group" "alb_target_groups" {
  count    = "${length(var.alb_target_groups)}"
  name     = "${var.stack_details["env"]}-${var.stack_details["stack_name"]}-${lookup(var.alb_target_groups[count.index],"name")}"
  port     = "${lookup(var.alb_target_groups[count.index],"container_port_to_expose")}"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    interval            = 60
    path                = "/${lookup(var.alb_target_groups[count.index],"context")}/"
    timeout             = 20
    healthy_threshold   = 2                                                           # Give them some breathing space
    unhealthy_threshold = 10
    matcher             = "200-499"                                                   #debug
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = ["aws_alb.alb"]
}

resource "aws_alb_listener" "listener" {
  port              = "80"
  protocol          = "HTTP"
  load_balancer_arn = "${aws_alb.alb.id}"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_target_groups.0.arn}" #jenkins
    type             = "forward"
  }
}

resource "aws_alb_listener_rule" "routing_rules" {
  count        = "${length(var.alb_target_groups)}"
  listener_arn = "${aws_alb_listener.listener.arn}"
  priority     = "${10 + count.index}"

  action {
    type             = "forward"
    target_group_arn = "${element(aws_alb_target_group.alb_target_groups.*.arn, count.index)}"
  }

  condition {
    field  = "path-pattern"
    values = ["/${lookup(var.alb_target_groups[count.index],"name")}/*"]
  }
}
