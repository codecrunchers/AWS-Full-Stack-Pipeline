/* ecs iam role and policies */
resource "aws_iam_role" "ecs_role" {
  name               = "${var.stack_details["stack_name"]}-ECS-Instance-Role"
  assume_role_policy = "${file("${path.module}/policies/ecs-role.json")}"
}

/* ecs service scheduler role */
resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name   = "${var.stack_details["stack_name"]}-ecs-service-role-policy"
  policy = "${file("${path.module}/policies/ecs-service-role-policy.json")}"
  role   = "${aws_iam_role.ecs_role.id}"
}

/* ec2 container instance role & policy */
resource "aws_iam_role_policy" "ecs_instance_role_policy" {
  name   = "ecs-instance-role-policy"
  policy = "${data.template_file.ecs_instance_role_policy.rendered}"
  role   = "${aws_iam_role.ecs_role.id}"
}

data "template_file" "ecs_instance_role_policy" {
  template = "${file("${path.module}/policies/ecs-instance-role-policy.json")}"

  vars {
    app_log_group_arn       = "${var.cloudwatch_log_handle}"
    ecs_agent_log_group_arn = "${var.cloudwatch_log_handle}"
  }
}

/* ec2 container instance policy to access ecr */
resource "aws_iam_role_policy" "ecs_ecr_role_policy" {
  name   = "${var.stack_details["stack_name"]}-ecs-ecr-role-policy"
  policy = "${file("${path.module}/policies/ecs-ecr-role-policy.json")}"
  role   = "${aws_iam_role.ecs_role.id}"
}

/* ec2 container instance policy to access sqs */
resource "aws_iam_role_policy" "ecs_sqs_access_policy" {
  name   = "${var.stack_details["stack_name"]}-ecs-sqs-access-policy"
  policy = "${file("${path.module}/policies/ecs-sqs-access-policy.json")}"
  role   = "${aws_iam_role.ecs_role.id}"
}

/* ec2 container instance policy to access sqs */
resource "aws_iam_role_policy" "ecs_kms_decrypt_policy" {
  name   = "${var.stack_details["stack_name"]}-ecs-kms-decrypt-policy"
  policy = "${file("${path.module}/policies/ecs-kms-decrypt-policy.json")}"
  role   = "${aws_iam_role.ecs_role.id}"
}

/* terraform base policy */
resource "aws_iam_role_policy" "terraform_base_policy" {
  name   = "${var.stack_details["stack_name"]}-terraform-base-policy"
  policy = "${file("${path.module}/policies/terraform-ec2-instance-policy.json")}"
  role   = "${aws_iam_role.ecs_role.id}"
}

/**
 * IAM profile to be used in auto-scaling launch configuration.
 */
resource "aws_iam_instance_profile" "ecs" {
  name = "${var.stack_details["stack_name"]}-Creds"
  path = "/"
  role = "${aws_iam_role.ecs_role.name}"
}
