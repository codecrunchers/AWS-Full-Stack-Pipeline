resource "aws_route53_zone" "main" {
  name   = "${var.dns_zone_name}"
  vpc_id = "${aws_vpc.default.id}"
}
