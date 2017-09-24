resource "aws_alb_target_group" "alb_target_groups" {
  count    = "${length(var.target_groups)}"
  name     = "${var.stack_details["env"]}-${lookup(var.target_groups[count.index],"name")}"
  port     = "${lookup(var.target_groups[count.index],"port")}"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    interval            = 60
    path                = "/${lookup(var.target_groups[count.index],"name")}/"
    timeout             = 20
    healthy_threshold   = 2
    unhealthy_threshold = 10
    matcher             = "200-499"                                            #workaround for debugging
  }
}

resource "aws_alb_listener" "listener" {
  port              = "80"
  protocol          = "HTTP"
  load_balancer_arn = "${aws_alb.alb.id}"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_target_groups.0.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener_rule" "routing_rules" {
  count        = "${length(var.target_groups)}"
  listener_arn = "${aws_alb_listener.listener.arn}"
  priority     = "${10 + count.index}"

  action {
    type             = "forward"
    target_group_arn = "${element(aws_alb_target_group.alb_target_groups.*.arn, count.index)}"
  }

  condition {
    field  = "path-pattern"
    values = ["/${lookup(var.target_groups[count.index],"name")}/*"]
  }
}
