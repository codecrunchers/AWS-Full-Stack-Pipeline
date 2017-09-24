# Out

output "public_subnet_cidr_blocks" {
  value = "${var.private_subnet_cidr_blocks}"
}

output "private_subnet_cidr_blocks" {
  value = "${var.private_subnet_cidr_blocks}"
}

output "id" {
  value = "${aws_vpc.default.id}"
}

output "public_subnet_ids" {
  value = ["${aws_subnet.public.*.id}"]
}

output "private_subnet_ids" {
  value = ["${aws_subnet.private.*.id}"]
}

output "cidr_block" {
  value = "${var.cidr_block}"
}

output "nat_gateway_ips" {
  value = ["${aws_eip.nat.*.public_ip}"]
}

output "nat_gateway_ids" {
  value = ["${aws_eip.nat.*.id}"]
}
