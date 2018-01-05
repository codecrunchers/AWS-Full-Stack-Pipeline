resource "aws_efs_file_system" "ecs_storage" {
  performance_mode = "generalPurpose"

  tags {
    "Name"      = "${var.stack_details["env"]}-${var.stack_details["stack_name"]}-Pipeline Storage"
    stack_id    = "${var.stack_details["stack_id"]}"
    stack_name  = "${var.stack_details["stack_name"]}"
    Environment = "${var.stack_details["env"]}"
    ServerRole  = "Bastion"
  }
}

variable "mt_target_count_workaround" {
  default = "2"
}

resource "aws_efs_mount_target" "efs_mt" {
  count           = "${var.mt_target_count_workaround}"           #TODO: "${length(var.private_subnet_ids)}" ? 
  file_system_id  = "${aws_efs_file_system.ecs_storage.id}"
  subnet_id       = "${var.private_subnet_ids[count.index]}"
  security_groups = ["${aws_security_group.pipeline-storage.id}"]
}
