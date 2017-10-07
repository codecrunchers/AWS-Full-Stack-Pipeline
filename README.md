# Docker Backed AutoScaling ECS Managed Amazon Pipelin

This is a  `fully managed` ECS/Container Driven build Continuous Delivery Platform.  

# Features
* Scalable Jenkins Build Masters.
* Sonar for source code analysis
* Nexus Artifactory
* Consul for internal service discovery
* Private Hosted Amazon DNS Zone ( developers don't ever worry about config such as + "_${ENV}" )
* Auto Registering Scalable Jenkins Build Slaves. *
* Uses Jenkins 2 Pipeline, Build for any Dev environment, just add Jenkins/Docker slave tasks & images in ECS
* Easily extendable with new services
* Secure Public / Private  VPC setup with NAT & IGW
* Jenkins Jobs to Create Deployable Development Environments sucvh Prod/QA/Staging *
* Automatic Peering to new VPCs for Deployment *

`* in the pipeline so to say`


## Initial Setup
Some manual steps at the moment, I'm working on these.  I'm using terraform 0.9.11 so no workspaces for now.
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
//* `terraform import aws_key_pair.deployer <YOUR_KEY_NAME>`
* `terraform import aws_s3_bucket.statefiles_for_app <YOU_S3_BUCKET>`
* `terraform import aws_dynamodb_table.terraform_statelock terraform_statelock <YOUR_S3_DYNAMODB_TABLE>` (alan.planet9.statefiles-pipeline-v2-lock)


## Bootstrapping
The docker images

## Jenkins
Set up Keys, and S3 Bucket
## Sonar
## Nexus
## VPN
* Doc [https://docs.openvpn.net/how-to-tutorialsguides/virtual-platforms/amazon-ec2-appliance-ami-quick-start-guide/]
Manually allow your own ip for a single ssh session. SSH in via the key we produced at the start, and run through the cli prompts - takes about 2 mns. At the end do a `sudo passwd openvpn` - you can now hit the HTTPS port of this machine and download your VPN config file.  

### Debug Box
From there, you can access the Debug box, this has access to the entire VPC.


##AWS Commands for Manual Steps
### DynamoDB
`aws dynamodb create-table \
    --table-name <statefile.tf.dyanodb.name> \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1`

### S3
`aws s3 mb s3://<bucket_name_from_statefile.tf>` (Check for Versioning?)

### Keypair
`aws ec2 create-key-pair --key-name <variables.tf.key_name> --query 'KeyMaterial' --output text > <variables.tf.key_name>.pem`
`chmod 400 pipeline-ecs.pem`



## TODO
* If New docker image is uploaded for Jenkins, the instance will use the the  files left on the EFS by the original Task invocatio, i.e. it won't update as you would expect as  the conifg is already in place. The disk needs to be wiped
