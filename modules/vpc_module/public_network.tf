resource "aws_subnet" "public" {
  count = "${length(var.vpc_public_subnet_cidr_blocks)}"

  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${element(var.vpc_public_subnet_cidr_blocks, count.index)}"
  availability_zone       = "${element(var.vpc_availability_zones, count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name        = "PublicSubnet"
    stack_id    = "${var.stack_details["stack_id"]}"
    stack_name  = "${var.stack_details["stack_name"]}"
    Environment = "${var.stack_details["env"]}"
  }
}

resource "aws_route" "public" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name        = "PublicRouteTable"
    stack_id    = "${var.stack_details["stack_id"]}"
    stack_name  = "${var.stack_details["stack_name"]}"
    Environment = "${var.stack_details["env"]}"
  }
}

resource "aws_route_table_association" "public" {
  count = "${length(var.vpc_public_subnet_cidr_blocks)}"

  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}
