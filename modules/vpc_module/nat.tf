resource "aws_eip" "nat" {
  count = "${length(var.public_subnet_cidr_blocks)}"

  vpc = true
}

resource "aws_nat_gateway" "default" {
  count = "${length(var.public_subnet_cidr_blocks)}"

  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"

  depends_on = ["aws_internet_gateway.default"]
}
