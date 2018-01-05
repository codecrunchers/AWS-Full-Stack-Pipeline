resource "aws_vpc" "default" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name        = "VPC"
    stack_id    = "${var.stack_details["stack_id"]}"
    stack_name  = "${var.stack_details["stack_name"]}"
    Environment = "${var.stack_details["env"]}"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id          = "${aws_vpc.default.id}"
  service_name    = "com.amazonaws.${data.aws_region.current.name}.s3"
  route_table_ids = ["${aws_route_table.public.id}", "${aws_route_table.private.*.id}"]
}

data "aws_region" "current" {
  current = true
}
