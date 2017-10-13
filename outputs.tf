output "account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}

output "vpn_public_ip" {
  value = "${module.vpn_instance.vpn_public_ip}"
}

output "vpn_public_link" {
  value = "https://${module.vpn_instance.vpn_public_ip}/"
}

output "vpn_private_ip" {
  value = "${module.vpn_instance.vpn_private_ip}"
}
