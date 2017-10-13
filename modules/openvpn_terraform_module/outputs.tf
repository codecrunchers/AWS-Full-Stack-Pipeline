output "vpn_public_ip" {
  value = "${aws_instance.vpn.public_ip}"
}

output "vpn_private_ip" {
  value = "${aws_instance.vpn.private_ip}"
}
