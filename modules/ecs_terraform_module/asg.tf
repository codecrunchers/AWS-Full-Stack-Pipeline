resource "aws_autoscaling_group" "ecs_asgrp" {
  name                      = "${var.stack_details["env"]}-ecs-asgrp"
  vpc_zone_identifier       = ["${var.subnets_amber}"]
  min_size                  = "${var.ecs_params["min_instances"]}"
  max_size                  = "${var.ecs_params["max_instances"]}"
  desired_capacity          = "${var.ecs_params["desired_instances"]}"
  launch_configuration      = "${aws_launch_configuration.ecs_launch_config.id}"
  enabled_metrics           = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupTotalInstances"]
  metrics_granularity       = "1Minute"
  health_check_grace_period = 1000
  target_group_arns         = ["${aws_alb_target_group.alb_target_groups.*.arn}"]

  lifecycle {
    create_before_destroy = true
  }

  tags = [
    {
      key                 = "Name"
      value               = "${var.stack_details["env"]} Pipeline Container Host"
      propagate_at_launch = true
    },
  ]
}

resource "aws_launch_configuration" "ecs_launch_config" {
  name_prefix          = "${var.stack_details["env"]}-${var.ecs_params["ecs_name"]}-ecs"
  security_groups      = ["${aws_security_group.ecs_instance_sg.id}"]
  image_id             = "${lookup(var.ecs_amis, var.aws_region)}"
  instance_type        = "${var.ecs_params["instance_type"]}"
  iam_instance_profile = "${aws_iam_instance_profile.app_instance_profile.id}"
  enable_monitoring    = true

  #  user_data                   = "#!/bin/bash\necho ECS_CLUSTER='${aws_ecs_cluster.ecs.id}' > /etc/ecs/ecs.config"
  user_data = "${data.template_file.user_data.rendered}"

  associate_public_ip_address = false

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/templates/user-data-ecsami.instance")}"

  vars {
    efs_url = "${aws_efs_mount_target.efs_mt.0.dns_name}"
    p9_env  = "${var.stack_details["env"]}"
  }
}

data "template_file" "instance_profile" {
  template = "${file("${path.module}/templates/instance-profile-policy.json")}"

  vars {
    app_log_group_arn       = "${var.cloudwatch_log_handle}"
    ecs_agent_log_group_arn = "${var.cloudwatch_log_handle}"
  }
}
