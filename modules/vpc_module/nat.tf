resource "aws_eip" "nat" {
  count = "${length(var.vpc_public_subnet_cidr_blocks)}"

  vpc = true
}

resource "aws_nat_gateway" "default" {
  count = "${length(var.vpc_public_subnet_cidr_blocks)}"

  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"

  depends_on = ["aws_internet_gateway.default"]

  #  tags {
  #    Name        = "NAT for  ${var.stack_details["stack_name"]}"
  #    stack_id    = "${var.stack_details["stack_id"]}"
  #    stack_name  = "${var.stack_details["stack_name"]}"
  #    Environment = "${var.stack_details["env"]}"
  #  }
  #https://www.terraform.io/docs/providers/aws/r/nat_gateway.html#tags
  # TF Ver maybe?
}
