module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "test"
  cidr = "172.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b"]
  private_subnets = ["172.0.0.0/24", "172.0.1.0/24"]
  public_subnets  = ["172.0.101.0/24", "172.0.102.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}