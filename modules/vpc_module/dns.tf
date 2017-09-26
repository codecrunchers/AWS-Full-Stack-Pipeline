resource "aws_route53_zone" "main" {
  name   = "${var.DnsZoneName}"
  vpc_id = "${aws_vpc.default.id}"
}
