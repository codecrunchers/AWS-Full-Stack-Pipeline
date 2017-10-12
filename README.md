# Enterprise Development and Deployment
## An ECS managed Docker auto scaling CI/CD Pipeline with a Production Env for AWS

This is a _fully managed_ ECS/Container Driven Continuous Delivery Platform for building, testing and Production deployment. You can add  additonal VPC/Environments such as Staging or QA, delivering steady state Production deployments.

A working, but basic enterprise deployment platform for deploying code in AWS. There is a cenrtal theme of deploying via a Managed Jenkins ECS Cluster.  There's plenty of work to do, incl. security concerns _(caveat emptor)_ - but out of the box with a few configuration steps you get:

* Secure Public / Private  VPC setup with NAT & IGW
* Service Discovery via a [Consul](http://www.consul.io) cluster backed by a Private AWS Hosted Zone

    No more ENV concerns, each VPC has it's own DNS, [db.mydomain.io](#nowhere) is correct in every env/VPC.  Developers don't ever worry about config such as + "_${ENV}" ) <somewhat work in practice>
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
* Multi AZ with EFS & RDS Storage
* Encrypted State with Locking enabled
* Secure keyless Key,Value store

## AWS Architecture
![Rough Idea with Second Prod VP:](./docs/images/Pipeline_Overview.png)
<a href="https://drive.google.com/uc?export=view&id=0B6rlckp3x7UkZjFTZTBEOTZoeVk"><img src="https://drive.google.com/uc?export=view&id=0B6rlckp3x7UkZjFTZTBEOTZoeVk" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

## Less Tech View
![Software Development Lifecycle](./docs/imgs/PipelineInPics.png)
<a href="https://drive.google.com/uc?export=view&id=0B6rlckp3x7UkUDA0NTdNOV9XY0k"><img src="https://drive.google.com/uc?export=view&id=0B6rlckp3x7UkUDA0NTdNOV9XY0k" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

## Initial Setup
Some manual steps at the moment, we're working on these.  Using terraform 0.9.11,  so no workspaces for now.

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

### <a name="state"></a> Importing State
```
terraform import aws_s3_bucket.statefiles_for_app <YOU_S3_BUCKET>
terraform import aws_dynamodb_table.terraform_statelock  <YOUR_S3_DYNAMODB_TABLE> #(e.g. alan.planet9.my.statefile
```

### Plan and Apply (this will cost money)
```bash
terraform plan
terraform apply
```

### Post Bootstrapping

The docker images are available here:
* [Demo NPM Project](https://github.com/codecrunchers/helloworld-npm) for pipeline build and Deploy
* [Jekins Node/NPM Slave](https://github.com/codecrunchers/jenkins-node-slave)
* [Jenkins Master](https://github.com/codecrunchers/jenkinsci)

These will need to be tagged and pushed, see script to run `post terraform apply`  It pulls most from DockerHub now

### Services
Once these have been pushed, the ALB Endpoint which appeared in the output of `terraform apply` can be accessed:
* Jenkins can be accessed at http://LOAD_BALANCER/jenkins/)
* Sonar can be accessed at http://LOAD_BALANCER/sonar/)
* Sonar can be accessed at http://LOAD_BALANCER/nexus/)

### Consul
Once on the VPN, every box has access to an internal Consul (cluster to come) 
```bash
[ec2-user@ip-10-0-1-68 ~]$ dig consul.cd-pipeline.io

; <<>> DiG 9.8.2rc1-RedHat-9.8.2-0.62.rc1.56.amzn1 <<>> consul.cd-pipeline.io
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 586
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 0

;; QUESTION SECTION:
;consul.cd-pipeline.io.		IN	A

;; ANSWER SECTION:
consul.cd-pipeline.io.	60	IN	A	10.0.1.27

;; Query time: 2 msec
;; SERVER: 10.0.0.2#53(10.0.0.2)
;; WHEN: Thu Oct 12 00:18:09 2017
;; MSG SIZE  rcvd: 55
➜  tf git:(master) dig @10.0.1.27 jenkinsci-8080.service.consul

; <<>> DiG 9.10.3-P4-Ubuntu <<>> @10.0.1.27 jenkinsci-8080.service.consul
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 47376
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 0

;; QUESTION SECTION:
;jenkinsci-8080.service.consul.	IN	A

;; ANSWER SECTION:
jenkinsci-8080.service.consul. 0 IN	A	10.0.1.203

;; Query time: 34 msec
;; SERVER: 10.0.1.27#53(10.0.1.27)
;; WHEN: Thu Oct 12 03:29:55 IST 2017
;; MSG SIZE  rcvd: 92
```

#### VPN
* [OpenVPN AMI Docs](https://docs.openvpn.net/how-to-tutorialsguides/virtual-platforms/amazon-ec2-appliance-ami-quick-start-guide/)

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
* Find way to force Jenkins to reload file from Docker image if new image
* Finalise consul and DNS
* Output all DNS entries
* Jobs for VPC Building
* VPC Peering module
* Configure Sonar
* Configure Nexus
* OSS VPN
* SSL
* Encrypt EFS
