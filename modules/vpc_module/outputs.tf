# Out
output "cidr_block" {
  value = "${aws_vpc.default.cidr_block}"
}

output "bastion_private_ip" {
  value = "${aws_instance.bastion.private_ip}"
}

output "vpc_public_subnet_cidr_blocks" {
  value = "${var.vpc_private_subnet_cidr_blocks}"
}

output "vpc_private_subnet_cidr_blocks" {
  value = "${var.vpc_private_subnet_cidr_blocks}"
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

output "nat_gateway_ips" {
  value = ["${aws_eip.nat.*.public_ip}"]
}

output "nat_gateway_ids" {
  value = ["${aws_eip.nat.*.id}"]
}
