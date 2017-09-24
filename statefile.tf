# Remote Statefile

# Cannot contain interpolations

terraform {
  backend "s3" {
    region  = "eu-west-1"
    bucket  = "statefiles-pipeline"
    key     = "statefiles/pipeline/prod.tfstate"
    acl     = "private"
    encrypt = true
  }
}

# Setup the region here
provider "aws" {
  region = "${var.region}"
}

# We want the account ID in the statefile for other resources
data "aws_caller_identity" "current" {}
