resource "aws_instance" "EC2" {
  ami             = "ami-00ca32bbc84273381"
  instance_type   = local.type
  key_name        = "maeve-ec2keypair-1a"
  subnet_id       = var.subnet_id
  vpc_security_group_ids = ["sg-0178cf3b07f16fb5d"]

  tags = {
    Name = local.name
  }
}

locals {
  name = "Hello2"
  type = "t3.micro"
}