resource "aws_route53_zone" "primary" {
  name   = "${var.dns_zone_name}"
  vpc_id = "${var.vpc_id}"

  tags {
    Name       = "${var.stack_details["env"]}-TLD"
    stack_name = "${var.stack_details["stack_name"]}"
    stack_id   = "${var.stack_details["stack_id"]}"
  }

  force_destroy = "${var.force_destroy}"
}

resource "aws_route53_record" "dns" {
  count   = "${length(var.zone_records)}"
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "${lookup(var.zone_records[count.index],"name")}"
  type    = "${lookup(var.zone_records[count.index],"type","A")}"
  ttl     = "${lookup(var.zone_records[count.index],"ttl","300")}"
  records = ["${lookup(var.zone_records[count.index],"record")}"]
}
