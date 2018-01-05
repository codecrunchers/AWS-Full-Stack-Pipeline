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
