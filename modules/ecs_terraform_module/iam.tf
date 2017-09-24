resource "aws_iam_role_policy" "instance_role_policy" {
  name   = "${var.stack_details["env"]}-${var.ecs_params["ecs_name"]}-instance-role"
  role   = "${aws_iam_role.app_instance_role.name}"
  policy = "${data.template_file.instance_profile.rendered}"
}

resource "aws_iam_role" "ecs_service_role" {
  name = "${var.stack_details["env"]}-${var.ecs_params["ecs_name"]}-role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs_service_policy" {
  name = "${var.stack_details["env"]}-${var.ecs_params["ecs_name"]}-service-policy"
  role = "${aws_iam_role.ecs_service_role.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:RegisterTargets"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "app_instance_role" {
  name = "${var.stack_details["env"]}-${var.ecs_params["ecs_name"]}-app-instance-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "app_instance_profile" {
  name = "${var.stack_details["env"]}-${var.ecs_params["ecs_name"]}-app-instance-profile"
  role = "${aws_iam_role.app_instance_role.name}"
}
