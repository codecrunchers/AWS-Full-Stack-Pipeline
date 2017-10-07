# Docker Backed AutoScaling ECS Managed Amazon Pipelin

## Initial Setup
Some manual steps at the moment, I'm working on these.
## Manual via Web Console
* Create your `S3` bucket (enable Versioning) and match it to the name in `statefile.tf`
* Create your `DynamoDB` instance , again matching the names in `statefile.tf`
* Create a keypair, matching the name to the value of `key_name` in `terraform.tfstate`

## Terraforming
This expects your AWS env vars to be exported, in my case (I use MFA && IAM)
* AWS_ACCESS_KEY_ID
* AWS_EXPIRATION_TOKEN 
* AWS_SECRET_ACCESS_KEY
* AWS_SECURITY_TOKEN
* AWS_SESSION_TOKEN

Run an `aws s3 ls` for a sanity check

### S3/Terraform Backend
* `terraform get`
* `terraform init`

### Importing State
* `terraform import aws_key_pair.deployer <YOUR_KEY_NAME>`
* `terraform import aws_s3_bucket.statefiles_for_app <YOU_S3_BUCKET>`
* `terraform import aws_dynamodb_table.terraform_statelock terraform_statelock <YOUR_S3_DYNAMODB_TABLE>`


## Bootstrapping
The docker images

## Jenkins
## Sonar
## Nexus
## VPN
* Doc [https://docs.openvpn.net/how-to-tutorialsguides/virtual-platforms/amazon-ec2-appliance-ami-quick-start-guide/]
