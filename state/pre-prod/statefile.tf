terraform {
  backend "s3" {
    region     = "eu-west-1"
    bucket     = "p9terraform"
    key        = "statefiles/pipeline/pre-prod.tfstate"
    acl        = "private"
    encrypt    = true
    lock_table = "statefiles-pipeline-pre-prod-tfstate-lock"
  }
}

#Manually Imported & Created
resource "aws_s3_bucket" "statefiles_for_app" {
  bucket = "p9terraform"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

#Manually Imported & Created
#AWS Will allow locking of statfiles via this db resource 
resource "aws_dynamodb_table" "terraform_statelock" {
  name           = "statefiles-pipeline-pre-prod-tfstate-lock"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  lifecycle {
    prevent_destroy = true
  }

  attribute {
    name = "LockID"
    type = "S"
  }
}

# Setup the region here
provider "aws" {
  region = "${var.stack_details["region"]}"
}

# We want the account ID in the statefile for other resources
data "aws_caller_identity" "current" {}

output "account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}
