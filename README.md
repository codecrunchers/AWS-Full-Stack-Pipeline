# Docker Backed AutoScaling ECS Managed Amazon Pipeline

This is a  `fully managed` ECS/Container Driven build Continuous Delivery Platform.

This is a working, but basic enterprise deployment platform for AWS - with a central theme of deploying via a Managed Jenkins ECS cluster.  There's plenty of work to do, incl. security concerns (caveat emptor) - but out of the box with a few configuration steps you get

* Secure Public / Private  VPC setup with NAT & IGW
* NAT between public and private subnets
* Service Discovery via a consul cluster backed by a Private AWS Hosted Zone (no more ENV concerns, each VPC has it's own DNS, db.p9.io is correct in every env/VPC -  developers don't ever worry about config such as + "_${ENV}" )
* An Internet Gateway  (IGW) for handling all traffic.
* An ECS backed managed cluster of Jenkins slaves with a governing master.
* Scalable Node/Javascript build slaves, lifecycle managed by ECS & Jenkins.
* A Jenkins 2.0 Master extended from [jenkins/jenkins](https://hub.docker.com/r/jenkins/jenkins/)  customised to run a build on first boot.
* Jenkins Jobs to Create Deployable Development Environments such as Prod/QA/Staging *
* Sonar for source code analysis
* Nexus Artifactory
* Easily extensible with new services
* Automatic Peering to new VPCs for Deployment *


## Initial Setup
Some manual steps at the moment, I'm working on these.  I'm using terraform 0.9.11 so no workspaces for now.

## Manual CLI Steps (or do the same  via Web Console)
1. [Create your `S3` bucket](#state) for state management, (enable Versioning & encryption) this is the value of bucket in `statefile.tf`
2. [Create your `DynamoDB` instance](#dynamo) , again matching the names in `statefile.tf` - same as Step 1
3. [Create a keypair](#keypair), matching the name to the value of `key_name` in `terraform.tfstate` save the .pem file as shown below.

## Initialising state and deploying via Terraforming
1. Install terraform, currently 0.9.11 (working on migration)

### S3/Terraform Backend
* `terraform get`
* `terraform init`
...This expects your AWS env vars to be exported, in my case (I use MFA && IAM)

* AWS_ACCESS_KEY_ID
* AWS_EXPIRATION_TOKEN 
* AWS_SECRET_ACCESS_KEY
* AWS_SECURITY_TOKEN
* AWS_SESSION_TOKEN

Run an `aws s3 ls` for a sanity check


### <a name="state"></a> Importing State
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


## AWS Commands for Manual Steps
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
* SSL
* Output all DNS entries
* Jobs for VPC Building
* VPC Peering module
