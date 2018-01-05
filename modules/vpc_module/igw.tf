resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name        = "Gateway for  ${var.stack_details["stack_name"]}"
    stack_id    = "${var.stack_details["stack_id"]}"
    stack_name  = "${var.stack_details["stack_name"]}"
    Environment = "${var.stack_details["env"]}"
  }
}
