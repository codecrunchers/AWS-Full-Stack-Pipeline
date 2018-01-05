variable "stack_details" {
  type = "map"
}

variable "vpc_id" {}

variable "force_destroy" {
  default = false
}

variable "dns_zone_name" {}

variable "zone_records" {
  type = "list"

  default = [
    {
      field = "value"
    },
    {
      field = "value"
    },
  ]
}
