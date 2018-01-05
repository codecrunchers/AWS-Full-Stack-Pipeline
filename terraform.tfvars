dns_zone = "my-cd-pipeline.io"

region = "eu-west-1"

pipeline_external_access_cidr_block = ["37.228.251.37/32", "83.70.128.30/32", "192.30.252.0/22", "185.199.108.0/22"] //Home,GitHUB*2

#TODO: Dup
#Key Name is Pattern _BUCKET_ID - see go.sh

key_name = "alan-e02c0de3-368d-4531-8ce8-b7d2cf2e34f8-key"

#Key Name is Pattern _BUCKET_ID - see go.sh
vpn_instance_details = {
  ami      = "ami-015fbb78"
  size     = "t2.micro"
  key_name = "alan-e02c0de3-368d-4531-8ce8-b7d2cf2e34f8-key"
}

nexus_definition = {
  docker_image_tag           = "sonatype/nexus:oss"
  name                       = "nexus"
  context                    = "nexus"
  host_port_to_expose        = "8081"
  container_port_to_expose   = "8081"
  instance_memory_allocation = "1024"
  instance_count             = "1"
}

jenkins_pipeline_definition = {
  docker_image_tag           = "codecrunchers/jenkinsci:latest"
  name                       = "jenkins"
  context                    = "jenkins"
  host_port_to_expose        = "8080"
  container_port_to_expose   = "8080"
  instance_memory_allocation = "512"
  instance_count             = "1"
  github_app_client_id       = "`"
  github_app_client_secret   = ""
}
