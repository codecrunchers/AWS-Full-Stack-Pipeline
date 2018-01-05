#Auto Scale Policy for Containers

resource "aws_autoscaling_policy" "autoscale_policy" {
  name                   = "${var.stack_details["env"]}-${var.stack_details["stack_name"]}-scale-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.ecs_asgrp.name}"
}

resource "aws_cloudwatch_metric_alarm" "reserved_mem_alarm" {
  alarm_name          = "${var.stack_details["env"]}-${var.stack_details["stack_name"]}-Mem-Alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "75"

  dimensions {
    ClusterName = "${aws_ecs_cluster.ecs.name}" #See : http://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ecs-metricscollected.html
  }

  alarm_description = "MemoryReservation > 75 for 2 minutes"
  alarm_actions     = ["${aws_autoscaling_policy.autoscale_policy.arn}"]
}
