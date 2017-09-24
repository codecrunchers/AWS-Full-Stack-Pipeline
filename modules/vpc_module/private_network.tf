resource "aws_subnet" "private" {
  count = "${length(var.private_subnet_cidr_blocks)}"

  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${element(var.private_subnet_cidr_blocks, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"

  tags {
    Name        = "PrivateSubnet"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table" "private" {
  count = "${length(var.private_subnet_cidr_blocks)}"

  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name        = "PrivateRouteTable"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

resource "aws_route" "private" {
  count = "${length(var.private_subnet_cidr_blocks)}"

  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.default.*.id, count.index)}"
}

resource "aws_route_table_association" "private" {
  count = "${length(var.private_subnet_cidr_blocks)}"

  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}
