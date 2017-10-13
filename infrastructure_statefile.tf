data "terraform_remote_state" "infrastructure" {
  backend = "s3"

  config = {
    region = "eu-west-1"
    bucket = "p9terraform"
    key    = "statefiles/infrastructure/${var.stack_details["env"]}.tfstate"
    acl    = "private"
  }
}
