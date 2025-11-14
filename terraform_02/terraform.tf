resource "aws_instance" "EC2" {
  ami           = "ami-00ca32bbc84273381"
  instance_type = "t3.micro"
  key_name = "maeve-ec2keypair-1a"
  subnet_id = "subnet-0719bb9859de06aba"
  security_groups = ["sg-0178cf3b07f16fb5d"]
  
  tags = {
    Name = "HelloWorld"
  }
}