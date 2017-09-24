resource "aws_instance" "debug_box" {
  ami                         = "ami-ebd02392"
  instance_type               = "t2.micro"
  subnet_id                   = "${module.vpc_pipeline.private_subnet_ids[0]}"
  associate_public_ip_address = false
  key_name                    = "pipeline"

  tags {
    Name = "Debug Box in Private Network"
  }
}
