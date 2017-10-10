# Enterprise Development and Deployment
## A Docker Backed auto scaling ECS Managed Amazon Pipeline with Production Env

This is a *fully managed* ECS/Container Driven Continuous Delivery Platform for building, testing and Production deployment

This is a working, but basic enterprise deployment platform for AWS - with a central theme of deploying via a Managed Jenkins ECS cluster.  There's plenty of work to do, incl. security concerns (caveat emptor) - but out of the box with a few configuration steps you get

* Secure Public / Private  VPC setup with NAT & IGW
* Service Discovery via a [Consul](http://www.consul.io) cluster backed by a Private AWS Hosted Zone 
---No more ENV concerns, each VPC has it's own DNS, [db.mydomain.io](#nowhere) is correct in every env/VPC.  Developers don't ever worry about config such as + "_${ENV}" ) <somewhat work in practice>
* A scalable ECS backed managed cluster of Jenkins slaves with a governing master.
* Scalable Node/Javascript build slaves, lifecycle managed by ECS & Jenkins.
* A Jenkins 2.0 Master extended from [jenkins/jenkins](https://hub.docker.com/r/jenkins/jenkins/)  customised to run a build on first boot.
* Jenkins Jobs to Create Deployable Development Environments such as Prod/QA/Staging *
* Sonar for source code analysis
* Nexus Artifactory
* Easily extensible with new services
* Automatic Peering to new VPCs for Deployment *
* A Bastion Jump Box accessible via
* A VPN
* Cloudwtach Logging for most features


## Initial Setup
Some manual steps at the moment, I'm working on these.  I'm using terraform 0.9.11 so no workspaces for now.

## Manual CLI Steps (or do the same  via Web Console)
1. [Create your `S3` bucket](#s3) for state management, (enable Versioning & encryption) this is the value of bucket in `statefile.tf`
2. [Create your `DynamoDB` instance](#dynamo), again matching the names in `statefile.tf` - same as Step 1
3. [Create a keypair](#keypair), matching the name to the value of `key_name` in `terraform.tfstate` save the .pem file as shown below.

## Jenkins GitHub Credentials
If you want your pirvate keys available, you need to load them into an S3 bucker #TODO: Set up Keys, and S3 Bucket


## Initialising state and deploying via Terraforming
Install terraform, currently 0.9.11 (working on migration)

### S3/Terraform Backend


```bash
git clone git@github.com:Plnt9/aws-pipeline-v2.git
cd aws-pipeline-v2
terraform get
terraform init
```
[<import state>](#state)

Run an `aws s3 ls` before you start for a sanity check.

###  Importing State
```
terraform import aws_s3_bucket.statefiles_for_app <YOU_S3_BUCKET>
terraform import aws_dynamodb_table.terraform_statelock terraform_statelock <YOUR_S3_DYNAMODB_TABLE> #(e.g. alan.planet9.my.statefile
```

### Plan and Apply
```bash
terraform plan
terraform apply
```

### Post Bootstrapping

The docker images are available here:
* [Demo NPM Project](https://github.com/codecrunchers/helloworld-npm) for pipeline build and Deploy
* [Jekins Node/NPM Slave](https://github.com/codecrunchers/jenkins-node-slave)
* [Jenkins Master](https://github.com/codecrunchers/jenkinsci)

These will need to be tagged and pushed, see script to run `post terraform apply`

### Services
Once these have been pushed, the ALB Endpoint which appeared in the output of `terraform apply` can be accessed:
* Jenkins can be accessed at http://LOAD_BALANCER/jenkins/)
* Sonar can be accessed at http://LOAD_BALANCER/sonar/)
* Sonar can be accessed at http://LOAD_BALANCER/nexus/)

#### VPN
* [Docs(https://docs.openvpn.net/how-to-tutorialsguides/virtual-platforms/amazon-ec2-appliance-ami-quick-start-guide/)

Manually allow your own ip for a single ssh session. SSH in via the key we produced at the start, and run through the cli prompts - takes about 2 mns. At the end do a `sudo passwd openvpn` - you can now hit the HTTPS port of this machine and download your VPN config file.  

#### Debug Box / Bastion / Jump Box
From there, you can access the Debug box, this has access to the entire VPC.

#### Sonar
You will need to manually configure Sonar for now.  Jenkins has 1 Sonar server configured, https://record.domain.tld/sonar/ (i.e. your ALB)

#### Nexus
Nexius is deployed, but likewise not configured


## AWS Commands for Manual Steps
### <a name="dynamodb"></a> DynamoDB
```bash
aws dynamodb create-table \
    --table-name <statefile.tf.dyanodb.name> \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1
```

### <a name="s3"></a> S3
`aws s3 mb s3://<bucket_name_from_statefile.tf>` (Manually enable & then check for Versioning?) `aws s3api get-bucket-versioning  --bucket <bucket_name_from_statefile.tf>`

### <a name="keypair"></a> Keypair
```bash
aws ec2 create-key-pair --key-name <variables.tf.key_name> --query 'KeyMaterial' --output text > <variables.tf.key_name>.pem
chmod 400 pipeline-ecs.pem
```

## TODO
* Lots
* If New docker image is uploaded for Jenkins, the instance will use the the  files left on the EFS by the original Task invocatio, i.e. it won't update as you would expect as  the conifg is already in place. The disk needs to be wiped
* Finalise consul and DNS
* SSL
* Output all DNS entries
* Jobs for VPC Building
* VPC Peering module
* Configure Sonar
* Configure Nexus

